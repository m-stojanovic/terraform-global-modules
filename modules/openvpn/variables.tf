variable "project" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The environment. (e.g., dev, staging, production)."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be deployed."
  type        = string
}

variable "subnet_id" {
  description = "The Public subnet ID of the VPC where resources will be deployed."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resources."
  type        = map(string)
}

variable "marketplace_access_server_ami" {
  description = "The AMI ID for the OpenVPN Access Server from the AWS Marketplace."
  type        = string
}

variable "instance_type" {
  description = "The instance type for the OpenVPN server."
  type        = string
  default     = "t3.small"
}

variable "volume_size" {
  description = "The size of the EBS volume in GiB for the OpenVPN instance."
  type        = number
}

variable "volume_type" {
  description = "The type of EBS volume for the OpenVPN instance (e.g., gp3, io1)."
  type        = string
}

variable "public_key" {
  description = "The public key to add to OpenVPN instance."
  type        = string
}

variable "whitelist_ips" {
  description = "The whitelisted IPs from where we can do SSH access to OpenVPN host."
  type        = list(string)
}