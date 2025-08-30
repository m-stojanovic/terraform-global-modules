variable "name" {
  description = "Name to be used on all resources as prefix"
}

variable "asg_max" {
  description = "Min number of instances to launch"
  default     = 1
}

variable "asg_min" {
  description = "Max number of instances to launch"
  default     = 1
}

variable "desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group."
  default     = 1
}

variable "ami" {
  description = "ID of AMI to use for the instance"
}

variable "placement_group" {
  description = "The Placement Group to start the instance in"
  default     = ""
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "instance_types" {
  type        = list(string)
  description = "The list of instance types"
}

variable "key_name" {
  description = "The key name to use for the instance"
  default     = ""
}
variable "aws_iam_instance_profile_name" {}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with"
  type        = list(string)
  default     = []
}

variable "subnet_id" {
  description = "The VPC Subnet ID to launch in"
  type        = list(any)
  default     = []
}

variable "associate_public_ip_address" {
  description = "If true, the EC2 instance will have associated public IP address"
  default     = false
}

variable "user_data" {
  description = "The user data to provide when launching the instance"
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  default     = {}
}

variable "enable_spot" {
  default = false
}

variable "on_demand_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances. Default: 0"
  default     = 0
}

variable "spot_allocation_strategy" {
  description = "How to allocate capacity across the Spot pools. Valid values: lowest-price. Default: lowest-price"
  default     = "lowest-price"
}

variable "spot_instance_pools" {
  description = "Number of Spot pools per availability zone to allocate capacity. EC2 Auto Scaling selects the cheapest Spot pools and evenly allocates Spot capacity across the number of Spot pools that you specify. Default: 1"
  default     = 3
}

variable "spot_max_price" {
  description = "Maximum price per unit hour that the user is willing to pay for the Spot instances. Default: on-demand price"
  default     = ""
}

variable "ebs_root_volume_size" {
  default = "8"
}

variable "ebs_root_volume_type" {
  default = "gp3"
}

variable "app_name" {}

variable "environment" {}

variable "credit_specification" {
  default = "standard"
}

variable "aws_user_data" {
  description = "Custom user-data"
  default     = ""
}

locals {
  on_demand_percentage_above_base_capacity = var.enable_spot ? 0 : 100
  environment_without_suffix               = join("", regex("(prod|dev|nxt)\\s*[\\w\\d_]+", var.environment))
}