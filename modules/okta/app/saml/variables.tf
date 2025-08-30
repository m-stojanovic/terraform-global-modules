variable "app_label" {
  description = "Display name of the Okta SAML app (e.g. Argo CD)"
  type        = string
}

variable "sso_url" {
  description = "SAML Assertion Consumer Service (ACS) URL (Dex callback URL)"
  type        = string
}

variable "audience" {
  description = "SAML audience URI, usually same as sso_url"
  type        = string
}

variable "subject_name_id_template" {
  description = "SAML Subject NameID template (default user.email)"
  type        = string
  default     = "user.email"
}

variable "single_logout_url" {
  description = "Optional SAML single logout URL"
  type        = string
  default     = null
}

variable "single_logout_issuer" {
  description = "Optional SAML single logout issuer"
  type        = string
  default     = null
}

variable "okta_groups" {
  description = <<-EOT
    List of groups to assign to this app.
    Each group is an object with:
      - id (string): Okta Group ID
      - priority (optional number): assignment priority, default 0
      - profile (optional map): extra app profile fields as a map
  EOT
  type = list(object({
    id       = string
    priority = optional(number)
    profile  = optional(map(string))
  }))
}

variable "okta_domain" {
  description = "Your Okta domain (e.g., yourorg.okta.com)"
  type        = string
}
