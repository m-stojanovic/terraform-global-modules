variable "name" {
  type        = string
  description = "Name of the IAM role resource"
  default     = ""
}
variable "description" {
  type        = string
  description = "Description of the IAM role resource"
  default     = ""
}
variable "path" {
  type        = string
  description = "Path"
  default     = "/"
}
variable "assume_role_policy" {
  type        = string
  description = "Policy to assume in the role"
  default     = ""
}

variable "iam_role_policy_name" {
  type        = string
  description = "Name for the inline IAM policy"
  default     = ""
}
variable "iam_role_policy" {
  type        = string
  description = "Inline IAM policy for the role"
  default     = ""
}
variable "policy_arn" {
  type        = string
  description = "ARN of the policy to attach"
  default     = ""
}

variable "create_policy_attachment" {
  type        = string
  description = "Assume policy for the role"
  default     = false
}
variable "create_iam_role_policy" {
  type        = string
  description = "Create inline IAM policy for the role"
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to the role."
  type        = map(string)
  default     = {}
}