variable "aws_region" {
  description = "AWS region name"
  default     = "eu-west-1"
}

variable "minimum_length" {
  description = "The minimum length of a password"
  default     = 16
}

variable "require_lowercase" {
  description = "Do we require lowercase characters in the password"
  default     = true
}

variable "require_uppercase" {
  description = "Do we require uppercase characters in the password"
  default     = true
}

variable "require_numbers" {
  description = "Do we require numbers in the password"
  default     = true
}

variable "require_symbols" {
  description = "Do we require symbols in the password"
  default     = true
}

variable "allow_user_change" {
  description = "Do we allow people to change their own password?"
  default     = true
}

variable "hard_expiry" {
  description = "Do we allow people to change passwords that have expired?"
  default     = false
}

variable "maximum_age" {
  description = "The maximum age of a password (in days)"
  default     = 30
}

variable "reuse_history" {
  description = "The number of previous passwords that users are prevented from reusing."
  default     = 4
}

