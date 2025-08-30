variable "project" {
  description = "Project name"
  type        = string  
}

variable "env" {
  description = "Environment name"
  type        = string  
}

variable "description" {
  description = "Description for the KMS key"
  type        = string
}

variable "alias" {
  description = "Alias name for KMS key"
  type        = string
}

variable "deletion_window_in_days" {
  description = "Alias name for KMS key"
  type        = string
}

variable "enable_key_rotation" {
  description = "Alias name for KMS key"
  type        = string
}

variable "policy" {
  description = "Insert KMS Policy"
  type        = any
}
