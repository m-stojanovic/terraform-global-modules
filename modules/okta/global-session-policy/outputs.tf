output "id" {
  description = "The ID of the Okta Global Session Policy."
  value       = okta_policy_signon.this.id
}

output "name" {
  description = "The name of the Okta Global Session Policy."
  value       = okta_policy_signon.this.name
}
