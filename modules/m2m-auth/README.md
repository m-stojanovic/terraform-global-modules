# Terraform Module — M2M Auth Gateway (API Gateway + Cognito)

This module provisions a machine‑to‑machine authentication gateway on AWS using **Amazon Cognito** (User Pool, Resource Server, App Clients) and **Amazon API Gateway v2 (HTTP)** with a **JWT Authorizer**. It supports **internal** and **multiple external** clients per backend “family”, path‑based routing, optional VPC Link to NLB/ALB, and optional custom domains.

---

## What the module creates

- Cognito **User Pool** (not publicly exposed).
- Cognito **Resource Server** with two scopes: `read`, `write`.
- One or more Cognito **App Clients** for each service *family*:
    - Internal clients get scopes `read` + `write`.
    - External clients get scope `read` only.
    - Additional external partners for the same family get their own dedicated App Client (Client ID/Secret).
- AWS **Secrets Manager** secrets that store each App Client’s secret.
- API Gateway (HTTP) with:
    - JWT Authorizer (Cognito) configured with **audience** = all App Client IDs.
    - Routes and proxy integrations per service (VPC Link or Internet).
    - Optional path‑prefix stripping and host‑based routing (`host_header`).
- Optional **VPC Link** (created if any service uses `VPC_LINK`).
- Optional **custom domain** for API Gateway using ACM certificate.

---

## High‑level flow

1. Client obtains an access token from Cognito using `client_credentials` with scope `devops-<env>-<name>/read` or `.../write` (identifier is `<project>-<environment>-<name>`).
2. Client calls `https://<custom_domain>/<family>/<...>` with `Authorization: Bearer <token>`.
3. API Gateway JWT Authorizer validates token audience and scope; route is allowed only if the route’s `required_scopes` contains the client’s scope.
4. API Gateway proxies the request to the configured integration (HTTP URL or NLB/ALB via VPC Link).

---

## Inputs (key variables)

- `project` (string) — Project slug (e.g., `devops`).
- `environment` (string) — Environment slug (e.g., `dev`).
- `name` (string) — Module base name (e.g., `auth`).
- `services` (map of objects) — Backend services to expose through the gateway. Each item supports:
    - `path_prefix` (string) — Base path in the gateway (e.g., `/client2old`).
    - `connection_type` (string) — `INTERNET` or `VPC_LINK`.
    - If `INTERNET`: `integration_uri` (string).
    - If `VPC_LINK`: `lb_name` (string), `lb_listener_port` (number), `host_header` (string).
    - `strip_prefix` (bool, default `true`).
    - `required_scopes` (list(string)) — e.g., `["read"]` or `["write"]`.
    - `methods` (list(string), default `["ANY"]`) — e.g., `["GET","HEAD"]` or `["POST","PUT","PATCH","DELETE"]`.
    - `family` (string) — Logical family name this service belongs to (e.g., `client2old`).
- `custom_domains` (map) — Optional. Keys are environment names; value holds `{ domain_name, hosted_zone_id, certificate_arn }`.
- `clients` (map of objects) — Defines client *families* and how many app clients to create per family.
    - **Important**: keys must be **unique**. The module uses the key to infer the *family*; the recommended pattern is to prefix with `ext_` or `int_` followed by the family name.
    - Object fields:
        - `type` (string) — `EXTERNAL` or `INTERNAL` (case insensitive).
        - `generate_secret` (bool) — whether to create and store client secret.
        - `additional_clients` (optional list(string)) — extra external partner suffixes; each produces an additional distinct App Client (e.g., `client1`, `client2`).

Networking inputs:
- `vpc_id` (string) — Required if any service uses `VPC_LINK`.
- `vpc_link_subnet_ids` (list(string)) — Private subnets for ENIs (VPC Link).
- `apigw_vpc_link_egress_ports` (list(number), default `[443]`).

Tagging:
- `tags` (map(string)) — Common tags; the module adds function/module tags on top.

---

## Root module usage

```hcl
module "m2m_auth" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/m2m-auth"

  project     = var.project
  environment = var.environment
  name        = "auth"

  vpc_id              = module.network.vpc_id
  vpc_link_subnet_ids = module.network.private_subnets

  services       = var.m2m_auth_services
  custom_domains = var.m2m_auth_custom_domains
  clients        = var.m2m_auth_clients

  tags = var.tags
}
```

---

## Example `dev.tfvars`

### Services (read/write split on the same path)

```hcl
m2m_auth_services = {
  client2old_write = {
    path_prefix      = "/client2old"
    connection_type  = "VPC_LINK"
    lb_name          = "nginx-external"
    lb_listener_port = 443
    host_header      = "client2old.dev.devops.io"
    strip_prefix     = true
    required_scopes  = ["write"]
    methods          = ["POST", "PUT", "PATCH", "DELETE"]
    family           = "client2old"
  }

  client2old_read = {
    path_prefix      = "/client2old"
    connection_type  = "VPC_LINK"
    lb_name          = "nginx-external"
    lb_listener_port = 443
    host_header      = "client2old.dev.devops.io"
    strip_prefix     = true
    required_scopes  = ["read"]
    methods          = ["GET", "HEAD"]
    family           = "client2old"
  }
}
```

### Custom domain (optional)

```hcl
m2m_auth_custom_domains = {
  dev = {
    domain_name     = "auth.dev.devops.io"
    hosted_zone_id  = "Zxxxxxxxxxxxxxxxxxxx"
    certificate_arn = "arn:aws:acm:ap-southeast-1:111111111111:certificate/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  }
}
```

### Clients (one INTERNAL + many EXTERNAL for the same family)

> Keys must be unique. Use the `ext_`/`int_` prefix + family name.  
> `additional_clients` creates extra external partners for the same family, each with its own Client ID/Secret.

```hcl
m2m_auth_clients = {
  ext_client2old = {
    type               = "EXTERNAL"
    generate_secret    = true
    additional_clients = ["client1", "client2]
  }

  int_client2old = {
    type               = "INTERNAL"
    generate_secret    = true
  }
}
```

This produces App Clients named like:
- `auth-client2old-EXTERNAL` (base external)
- `auth-client2old-client1-EXTERNAL` (extra partner)
- `auth-client2old-client2-EXTERNAL` (extra partner)
- `auth-client2old-INTERNAL` (internal)

Each App Client secret is stored in AWS Secrets Manager with a predictable path, e.g.:  
`access_management/cognito.<env>.<name>.<family>.<type>[.<partner>].client_secret`

---

## Outputs (selected)

- `client_ids` — map of logical client keys to Cognito App Client IDs.
- `client_names` — map of logical client keys to App Client names.
- `client_secret_secret_arns` — map of logical client keys to Secrets Manager Secret ARNs.
- `cognito_issuer` — Cognito OIDC issuer URL.
- `token_url` — Cognito token endpoint URL.
- `api_gateway_endpoint` — Default API Gateway endpoint.
- `custom_domain_api_mapping_urls` — Map of base URLs for any custom domains created.

---

## How to add another external client for an existing family

Add the partner name to `additional_clients` of the external family:

```hcl
m2m_auth_clients = {
  ext_client2old = {
    type               = "EXTERNAL"
    generate_secret    = true
    additional_clients = ["client1", "clientx"]  # added clientx
  }
  int_client2old = {
    type               = "INTERNAL"
    generate_secret    = true
  }
}
```

Apply the plan. A new App Client `auth-client2old-clientx-EXTERNAL` will be created with its own Client ID/Secret.



---

## Removing a client

Delete its entry (or remove the partner from `additional_clients`) and apply. Terraform will remove the corresponding App Client and its Secret without affecting other clients. API Gateway authorizer audience will be updated automatically (no downtime).

---

## Testing with curl

Set environment variables (adjust to your environment/region):

```bash
export COGNITO_DOMAIN="devops-dev-auth.auth.ap-southeast-1.amazoncognito.com"
export TOKEN_URL="https://${COGNITO_DOMAIN}/oauth2/token"
export SCOPE_READ="devops-dev-auth/read"
export SCOPE_WRITE="devops-dev-auth/write"

export API_BASE="https://auth.dev.devops.io"
export FAMILY="client2old"
```

### 1) Get a token for an EXTERNAL client (read‑only)

```bash
# Replace with the external client's credentials
export EXT_CLIENT_ID="xxxxxxxxxxxxxxxxxxxxxxxxxx"
export EXT_CLIENT_SECRET="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

EXT_TOKEN=$(curl -s -u "${EXT_CLIENT_ID}:${EXT_CLIENT_SECRET}"   -H "Content-Type: application/x-www-form-urlencoded"   -d "grant_type=client_credentials&scope=${SCOPE_READ}"   "${TOKEN_URL}" | jq -r '.access_token')

echo "${EXT_TOKEN}" | head -c 30 && echo "…"
```

### 2) Call a read endpoint

```bash
curl -i -H "Authorization: Bearer ${EXT_TOKEN}"   "${API_BASE}/${FAMILY}/health"
```

### 3) Get a token for an INTERNAL client (read + write)

```bash
# Replace with the internal client's credentials
export INT_CLIENT_ID="yyyyyyyyyyyyyyyyyyyyyyyyyy"
export INT_CLIENT_SECRET="yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy"

INT_TOKEN=$(curl -s -u "${INT_CLIENT_ID}:${INT_CLIENT_SECRET}"   -H "Content-Type: application/x-www-form-urlencoded"   -d "grant_type=client_credentials&scope=${SCOPE_WRITE}"   "${TOKEN_URL}" | jq -r '.access_token')

echo "${INT_TOKEN}" | head -c 30 && echo "…"
```

### 4) Call a write endpoint (example)

```bash
curl -i -X POST -H "Authorization: Bearer ${INT_TOKEN}"   -H "Content-Type: application/json"   -d '{"ping":"pong"}'   "${API_BASE}/${FAMILY}/some-resource"
```

Notes:
- If you do not want to use `jq`, you can parse the token with another JSON tool or inspect the full response.
- External tokens should work for GET/HEAD routes; write methods require `SCOPE_WRITE`.

---

## Tips & notes

- **Single path per family**: both read and write services use the same `path_prefix` so your public URL is stable: `https://<domain>/<family>/…`. Allowed methods and required scopes are split by service entry.
- **VPC Link** is created once and reused when any service needs it.
- **Zero‑downtime**: changing clients updates the authorizer audience; changing routes/methods updates the stage with auto‑deploy.
- **Secrets naming** is predictable; rotate by re‑creating the client or updating the secret as needed.
- **Host header** + TLS SNI is supported for NLB TLS listeners via `host_header` and `tls_config.server_name_to_verify`.


