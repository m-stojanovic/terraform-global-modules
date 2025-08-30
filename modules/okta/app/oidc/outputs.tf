output "app_id" {
  value = okta_app_oauth.this.id
}

output "client_id" {
  value       = okta_app_oauth.this.client_id
  description = "OIDC client ID."
}

output "client_secret" {
  value       = okta_app_oauth.this.client_secret
  description = "OIDC client secret."
  sensitive   = true
}
