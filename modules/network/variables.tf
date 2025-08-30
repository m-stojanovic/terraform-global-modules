################ VPC Variables ################

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}

variable "cidr" {
  description = "The CIDR block for the VPC. Default value is a valid CIDR, but not acceptable by AWS and should be overridden"
  type        = string
  default     = "0.0.0.0/0"
}

variable "public_subnets" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}

################ VPC Endpoint Variables ################

variable "vpc_endpoints" {
  description = "A list of VPC endpoints to create in addition to default ones"
  default     = null
}

################ Generel Info about Account/Project ################

variable "region" {
  description = "Region to be used on all the resources as identifier"
  type        = string
}

variable "environment" {
  description = "Environment to be used on all the resources as identifier"
  type        = string
}

variable "project" {
  description = "Project name to be used on all the resources as identifier"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# NAT Gateway
variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`"
  type        = bool
  default     = false
}

# Peering
variable "request_peering" {
  description = "Add default peering connections."
  type        = bool
  default     = true
}

variable "shared_aws_account_id" {
  description = "The AWS Shared account id."
  type        = string
  default     = ""
}

variable "shared_vpc_id" {
  description = "The AWS Shared account VPC id."
  type        = string
  default     = ""
}

variable "shared_vpc_cidr" {
  description = "The AWS Shared account VPC cidr."
  type        = string
  default     = ""
}
