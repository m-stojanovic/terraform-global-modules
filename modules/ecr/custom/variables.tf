variable "repository_name" {
  description = "ECR repository name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "number_of_images_to_keep" {
  description = "Number of images to keep"
  type        = number
}

variable "days_of_untagged_images_to_keep" {
  description = "Number of days to keep untagged images"
  type        = number
  default     = 1
}

variable "principal" {
  description = "ECR principal"
  type        = string
  default     = ""
}

variable "scan_on_push" {
  description = "Enable scan on push"
  type        = bool
  default     = true
}
