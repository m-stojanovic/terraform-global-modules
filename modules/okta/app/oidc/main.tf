###### The Okta Terraform provider doesn’t currently offer a dedicated resource to manage the "OpenID Connect ID Token" settings in the OIDC application

terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

resource "okta_app_oauth" "this" {
  consent_method            = var.consent_method
  issuer_mode               = var.issuer_mode
  label                     = var.label
  type                      = var.type
  redirect_uris             = var.redirect_uris
  post_logout_redirect_uris = var.post_logout_redirect_uris

  grant_types                = ["authorization_code", "refresh_token"]
  token_endpoint_auth_method = var.token_endpoint_auth_method

  app_links_json        = var.app_links_json
  app_settings_json     = var.app_settings_json
  authentication_policy = var.authentication_policy
  implicit_assignment   = var.implicit_assignment
  login_scopes          = var.login_scopes
  omit_secret           = var.omit_secret
  pkce_required         = var.pkce_required
  refresh_token_leeway  = var.refresh_token_leeway
  response_types        = var.response_types
}

resource "okta_app_oauth_api_scope" "this" {
  app_id = okta_app_oauth.this.id
  issuer = "https://trial-1744233.okta.com"
  scopes = var.okta_app_oauth_api_scopes
}

resource "okta_app_user_schema_property" "this" {
  count       = var.okta_app_user_schema_property ? 1 : 0
  app_id      = okta_app_oauth.this.id
  description = "Managed by Terraform"
  index       = var.index
  title       = var.title
  type        = var.schema_property_type
  master      = var.master
  scope       = var.scope

  permissions = "READ_ONLY"
  required    = false
  enum        = var.enum

  dynamic "one_of" {
    for_each = var.one_of
    content {
      const = one_of.value.const
      title = one_of.value.title
    }
  }
}
