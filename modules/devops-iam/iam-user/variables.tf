variable "user_name" {
  type        = string
  description = "The username of the user"
}

variable "path" {
  type        = string
  default     = "/"
  description = "The path for the user"
}

variable "title" {
  type        = string
  description = "The job title of the user"
}

variable "access_level" {
  type        = string
  description = "The access level of the user"
}

variable "email" {
  type        = string
  description = "The email of the user"
}

variable "name" {
  type        = string
  description = "The name of the user"
}

variable "force_destroy" {
  type        = string
  default     = false
  description = "Destroy user even if it has non-Terraform-managed IAM access keys, login profile or MFA devices."
}

variable "groups" {
  type        = list(string)
  default     = []
  description = "A list of groups that the user should be part of"
}

variable "create_access_keys" {
  type        = string
  default     = true
  description = "Whether to create access/secret keys for the user"
}

variable "create_password" {
  type        = string
  default     = true
  description = "Whether to create a password or not"
}

variable "pgp_key" {
  type        = string
  description = "A base-64 encoded PGP public key"
}

variable "password_length" {
  type        = string
  default     = "16"
  description = "The length of the user password"
}

variable "password_reset_required" {
  default     = false
  description = "Whether the user should be forced to reset the generated password on resource creation"
}

variable "upload_ssh_key" {
  type        = string
  default     = false
  description = "Whether to upload a ssh key for code commit"
}

variable "encoding" {
  type        = string
  default     = "SSH"
  description = "The public key encoding format to use in the response. Acceptable values are SSH & PEM"
}

variable "public_key" {
  type        = string
  default     = ""
  description = "The SSH public key. The public key must be encoded in ssh-rsa format or PEM format."
}