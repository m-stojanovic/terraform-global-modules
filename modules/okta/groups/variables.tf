variable "name" {
  description = "Name of the Okta group"
  type        = string
}

variable "description" {
  description = "Description of the group"
  type        = string
}

variable "custom_profile_attributes" {
  description = "Optional custom profile attributes"
  type        = map(string)
  default     = {}
}

variable "role_assignments" {
  description = "List of roles to assign to this group"
  type = list(object({
    admin_role    = string
    target_apps   = optional(set(string), [])
    target_groups = optional(set(string), [])
  }))
  default = []
}

variable "role_notification_enabled" {
  description = "Enable notifications for role assignment"
  type        = bool
  default     = true
}

variable "rules" {
  description = "List of rules that assign users to the group"
  type = list(object({
    name              = string
    enabled           = bool
    cascade_on_delete = bool
    expression_value  = string
  }))
}
