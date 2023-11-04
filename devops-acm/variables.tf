variable "domain_name" {
  type        = string
  description = "The name of the domain that this ACM certificate will be validated against"
}

variable "domain_zone_id" {
  type        = string
  description = "The ID of the DNS zone"
}

variable "domain_name_tag" {
  type        = string
  description = "A tag for the domain name"
}

variable "aws_region" {
  type        = string
  description = "The AWS region to create resources in"
}

variable "devops_main_access_key" {
  type        = string
  description = "The access key for the Devops main account"
}

variable "devops_main_secret_key" {
  type        = string
  description = "The secret key for the Devops main account"
}

variable "devops_dev_access_key" {
  type        = string
  description = "The access key for the Devops development account"
}

variable "devops_dev_secret_key" {
  type        = string
  description = "The secret key for the Devops development account"
}
