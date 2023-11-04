variable "group_name" {
  type        = string
  description = "The name of the IAM group"
}

variable "path" {
  type        = string
  default     = "/"
  description = "The path for the group"
}

variable "attach_policies" {
  type        = string
  default     = "true"
  description = "Whether to attach policies to groups or not"
}

variable "computed_number_of_policies" {
  type        = string
  description = "The number of policies to attach to the group"
}

variable "group_policies" {
  type        = list(string)
  default     = []
  description = "A list of IAM group policy ARNs"
}