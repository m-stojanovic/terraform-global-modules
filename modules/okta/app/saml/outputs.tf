output "app_id" {
  description = "Okta SAML App ID"
  value       = okta_app_saml.this.id
}

output "sso_url" {
  description = "SSO URL (ACS) for this SAML app"
  value       = okta_app_saml.this.sso_url
}

output "metadata_url" {
  description = "Okta SAML Metadata URL - use this in Dex config"
  value       = "https://${var.okta_domain}/app/${okta_app_saml.this.id}/sso/saml/metadata"
}
