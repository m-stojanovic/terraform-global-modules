locals {
  services_needing_vpc_link = {
    for k, v in var.services : k => v
    if lookup(v, "connection_type", "INTERNET") == "VPC_LINK"
  }
  need_vpc_link = length(local.services_needing_vpc_link) > 0

  client_base = {
    for ck, cfg in var.clients :
    ck => {
      parts           = split("_", ck)
      family          = length(split("_", ck)) >= 2 ? split("_", ck)[1] : ck
      partner         = length(split("_", ck)) >= 3 ? split("_", ck)[2] : ""
      type            = upper(cfg.type)
      generate_secret = try(cfg.generate_secret, true)
      additional      = try(cfg.additional_clients, [])
    }
  }

  client_expanded = merge({ for ck, c in local.client_base : "${c.family}|${ck}" => { family = c.family, client_key = ck, type = c.type, partner = c.partner } }, merge([for ck, c in local.client_base : { for p in c.additional : "${c.family}|${ck}-${p}" => { family = c.family, client_key = "${ck}-${p}", type = c.type, partner = p } }]...))
}

locals {
  expanded_routes = flatten([
    for k, v in var.services : [
      for m in lookup(v, "methods", ["ANY"]) : {
        key    = k
        method = upper(m)
        cfg    = v
      }
    ]
  ])
  route_map = { for r in local.expanded_routes : "${r.key}:${r.method}" => r }
}

data "aws_lb" "svc" {
  for_each = local.services_needing_vpc_link
  name     = each.value.lb_name
}

data "aws_lb_listener" "svc" {
  for_each          = local.services_needing_vpc_link
  load_balancer_arn = data.aws_lb.svc[each.key].arn
  port              = each.value.lb_listener_port
}

resource "aws_cognito_user_pool" "this" {
  name = "${var.project}-${var.environment}-${var.name}-user-pool"

  user_pool_add_ons {
    advanced_security_mode = "OFF"
  }

  lifecycle {
    ignore_changes = [schema]
  }

  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = false
  }

  tags = merge(var.tags, tomap({ "${var.project}:ModuleName" = "m2m-auth", "${var.project}:TechnicalFunction" = "access_management" }))
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = "${var.project}-${var.environment}-${var.name}"
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_resource_server" "this" {
  user_pool_id = aws_cognito_user_pool.this.id
  identifier   = "${var.project}-${var.environment}-${var.name}"
  name         = "${var.project}-${var.environment}-${var.name}-api"

  scope {
    scope_name        = "read"
    scope_description = "Read access"
  }
  scope {
    scope_name        = "write"
    scope_description = "Write access"
  }
}

resource "aws_cognito_user_pool_client" "clients" {
  for_each = local.client_expanded

  name         = "auth-${each.value.family}${each.value.partner != "" ? "-${each.value.partner}" : ""}-${each.value.type}"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = lower(each.value.type) == "internal" ? ["${aws_cognito_resource_server.this.identifier}/read", "${aws_cognito_resource_server.this.identifier}/write"] : ["${aws_cognito_resource_server.this.identifier}/read"]
  supported_identity_providers         = ["COGNITO"]
  prevent_user_existence_errors        = "ENABLED"

  access_token_validity  = 60
  id_token_validity      = 60
  refresh_token_validity = 5

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
  explicit_auth_flows = []
}

resource "aws_secretsmanager_secret" "client_secret" {
  for_each = aws_cognito_user_pool_client.clients

  name                    = "access_management/cognito.${var.environment}.${var.name}.${local.client_expanded[each.key].family}.${lower(local.client_expanded[each.key].type)}${local.client_expanded[each.key].partner != "" ? ".${local.client_expanded[each.key].partner}" : ""}.client_secret"
  description             = "AWS Cognito client secret (${each.key})"
  recovery_window_in_days = 0

  tags = merge(var.tags, tomap({ "${var.project}:ModuleName" = "m2m-auth", "${var.project}:TechnicalFunction" = "secret_management" }))
}

resource "aws_secretsmanager_secret_version" "client_secret" {
  for_each = aws_cognito_user_pool_client.clients

  secret_id     = aws_secretsmanager_secret.client_secret[each.key].id
  secret_string = aws_cognito_user_pool_client.clients[each.key].client_secret
}

resource "aws_security_group" "this" {
  name   = "${var.project}-${var.environment}-${var.name}-apigw-vpc-link"
  vpc_id = var.vpc_id

  dynamic "egress" {
    for_each = var.apigw_vpc_link_egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = merge(var.tags, tomap({ "${var.project}:ModuleName" = "m2m-auth", "${var.project}:TechnicalFunction" = "network" }))
}

resource "aws_apigatewayv2_vpc_link" "this" {
  count              = local.need_vpc_link ? 1 : 0
  name               = "${var.project}-${var.environment}-${var.name}-vpc-link-${substr(sha1(join(",", var.vpc_link_subnet_ids)), 0, 8)}"
  subnet_ids         = var.vpc_link_subnet_ids
  security_group_ids = [aws_security_group.this.id]
  tags               = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_api" "this" {
  name          = "${var.project}-${var.environment}-${var.name}-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "this" {
  name             = "${var.project}-${var.environment}-${var.name}-jwt-authorizer"
  api_id           = aws_apigatewayv2_api.this.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [for c in aws_cognito_user_pool_client.clients : c.id]
    issuer   = "https://${aws_cognito_user_pool.this.endpoint}"
  }
}

resource "aws_apigatewayv2_integration" "service" {
  for_each = var.services

  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "HTTP_PROXY"
  integration_method     = "ANY"
  payload_format_version = "1.0"

  connection_type    = lookup(each.value, "connection_type", "INTERNET")
  connection_id      = lookup(each.value, "connection_type", "INTERNET") == "VPC_LINK" ? aws_apigatewayv2_vpc_link.this[0].id : null
  integration_uri    = lookup(each.value, "connection_type", "INTERNET") == "VPC_LINK" ? data.aws_lb_listener.svc[each.key].arn : each.value.integration_uri
  request_parameters = merge(lookup(each.value, "strip_prefix", true) ? { "overwrite:path" = "/$request.path.proxy" } : {}, contains(keys(each.value), "host_header") ? { "overwrite:header.host" = each.value.host_header } : {})

  dynamic "tls_config" {
    for_each = (lookup(each.value, "connection_type", "INTERNET") == "VPC_LINK" && lookup(each.value, "lb_listener_port", 80) == 443 && contains(keys(each.value), "host_header")) ? [1] : []
    content {
      server_name_to_verify = each.value.host_header
    }
  }
}

resource "aws_apigatewayv2_route" "service" {
  for_each = local.route_map

  api_id               = aws_apigatewayv2_api.this.id
  route_key            = "${each.value.method} ${each.value.cfg.path_prefix}/{proxy+}"
  target               = "integrations/${aws_apigatewayv2_integration.service[each.value.key].id}"
  authorization_type   = "JWT"
  authorizer_id        = aws_apigatewayv2_authorizer.this.id
  authorization_scopes = lookup(each.value.cfg, "required_scopes", [])
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.this.arn
    format = jsonencode({
      requestId          = "$context.requestId"
      ip                 = "$context.identity.sourceIp"
      requestTime        = "$context.requestTime"
      httpMethod         = "$context.httpMethod"
      routeKey           = "$context.routeKey"
      status             = "$context.status"
      protocol           = "$context.protocol"
      responseLength     = "$context.responseLength"
      integrationLatency = "$context.integrationLatency"
      responseLatency    = "$context.responseLatency"
      errorMessage       = "$context.error.message"
    })
  }
}

resource "aws_apigatewayv2_domain_name" "custom" {
  for_each = { for k, v in var.custom_domains : k => v if k == var.environment }

  domain_name = each.value.domain_name
  domain_name_configuration {
    certificate_arn = each.value.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "custom" {
  for_each = { for k, v in var.custom_domains : k => v if k == var.environment }

  api_id      = aws_apigatewayv2_api.this.id
  domain_name = aws_apigatewayv2_domain_name.custom[each.key].domain_name
  stage       = aws_apigatewayv2_stage.this.name
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/apigw/${var.project}-${var.environment}-${var.name}"
  retention_in_days = 14
  tags              = merge(var.tags, tomap({ "${var.project}:ModuleName" = "m2m-auth", "${var.project}:TechnicalFunction" = "network" }))
}