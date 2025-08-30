variable "username" {
  type        = string
  description = "The name of the IAM user"
}

variable "environment_name_iam" {
  type        = string
  description = "The name of the environment for the IAM roles"
}

variable "create_pipeline" {
  type        = string
  default     = false
  description = "Whether to create build pipeline iam resources"
}

