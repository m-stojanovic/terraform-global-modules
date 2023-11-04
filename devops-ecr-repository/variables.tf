variable "repository_name" {
}

variable "number_of_images_to_keep" {
}

variable "days_of_untagged_images_to_keep" {
  default = "1"
}

variable "principal" {
  default = ""
}

variable "scan_on_push" {
  default = true
}