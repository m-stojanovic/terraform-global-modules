variable "organization_name" {
  type        = string
  description = "(Required) Name of organization to use for resource management."
}

variable "create_new_organization" {
  type        = bool
  description = "(Optional) Whether to create a new organization or use an existing one. Defaults to false."
  default     = false
}

variable "organization_email" {
  type        = string
  description = "(Optional) Email of owner for organization. **Required** when creating new organization."
  default     = "techops@devops.co"
}

variable "ssh_key_id" {
  type        = string
  description = "The SSH Private key ID. Added manually through UI. We do not want this key in the state file."
  default     = "sshkey-VwJWnFDTQvM9pHEA"
}
