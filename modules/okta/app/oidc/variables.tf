variable "label" {
  description = "The label displayed in Okta."
  type        = string
  default     = null
}

variable "consent_method" {
  description = "OIDC consent method (\"REQUIRED\", \"OPTIONAL\", or \"NONE\")."
  type        = string
}

variable "issuer_mode" {
  description = "Issuer mode for OIDC app (\"okta\" or \"custom\")."
  type        = string
}

variable "type" {
  description = "OIDC application type (\"web\" or \"native\")."
  type        = string
  default     = "web"
}

variable "redirect_uris" {
  description = "OIDC redirect URIs."
  type        = list(string)
  default     = []
}

variable "post_logout_redirect_uris" {
  description = "OIDC post-logout redirect URIs."
  type        = list(string)
  default     = []
}

variable "token_endpoint_auth_method" {
  description = "OIDC token endpoint authentication method (\"client_secret_post\", \"client_secret_basic\", or \"none\")."
  type        = string
}

variable "app_links_json" {
  description = "JSON map of app links."
  type        = any
}

variable "app_settings_json" {
  description = "JSON object for app-specific settings."
  type        = any
  default     = {}
}

variable "authentication_policy" {
  description = "ID of the Authentication Policy assigned to the app."
  type        = string
  default     = null
}

variable "implicit_assignment" {
  description = "Whether app is implicitly assigned."
  type        = bool
  default     = false
}

variable "login_scopes" {
  description = "Login scopes to assign."
  type        = list(string)
  default     = []
}

variable "omit_secret" {
  description = "Whether to omit the client secret."
  type        = bool
  default     = false
}

variable "pkce_required" {
  description = "Whether PKCE is required."
  type        = bool
  default     = false
}

variable "sign_on_mode" {
  description = "Sign-on mode for the OIDC app."
  type        = string
  default     = "OPENID_CONNECT"
}

variable "refresh_token_leeway" {
  description = "Leeway in seconds for refresh token expiration."
  type        = number
  default     = 0
}

variable "response_types" {
  description = "Response types for the OIDC app."
  type        = list(string)
  default     = ["code"]

}

variable "okta_app_oauth_api_scopes" {
  description = "List of API scopes for the OIDC app."
  type        = list(string)
  default     = []
}

###### schema properties configuration ######
variable "okta_app_user_schema_property" {
  description = "Whether to create a user schema property for the app."
  type        = bool
  default     = false
}


variable "index" {
  description = "The index (API name) for the user schema property."
  type        = string
  default     = null
}

variable "title" {
  description = "The title (display name) for the user schema property."
  type        = string
  default     = null
}

variable "schema_property_type" {
  description = "The type for the user schema property."
  type        = string
  default     = "string"
}

variable "master" {
  description = "The master for the user schema property."
  type        = string
  default     = "PROFILE_MASTER"
}

variable "scope" {
  description = "The scope for the user schema property."
  type        = string
  default     = "SELF"
}

variable "description" {
  description = "The description for the user schema property."
  type        = string
  default     = "Managed by Terraform"
}

variable "enum" {
  description = "Enum values for the user schema property."
  type        = list(string)
  default     = []
}

variable "one_of" {
  description = "List of maps defining 'one_of' entries (with const and title)."
  type = list(object({
    const = string
    title = string
  }))
  default = []
}
