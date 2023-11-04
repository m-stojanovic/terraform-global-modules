variable "zone_name" {
  type        = string
  description = "The name of the DNS zone"
}

variable "environment_name" {
  type        = string
  description = "The name of the environment"
}

variable "domain" {
  type        = string
  description = "The name of the domain eg. Devops"
}

variable "is_zone_private" {
  type        = string
  default     = "true"
  description = "Whether the DNS zone is private or not"
}

variable "associated_vpcs" {
  type        = list(string)
  default     = []
  description = "List of VPCs to associate with the DNS zone"
}

variable "associated_vpcs_count" {
  type        = string
  description = "The number of VPCs to associate with the DNS zone"
}

variable "first_vpc" {
  type        = string
  description = "The ID of the first VPC to associate with the DNS zone"
}