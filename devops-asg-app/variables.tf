variable "app_name" {
  type = string
}

variable "instance_count" {
  type = string
}

variable "instance_types" {
  type = list(string)
}

variable "deregistration_delay" {
  default = "30"
}

variable "aws_iam_instance_profile_name" {
  type = string
}

variable "ami" {
  type = string
}

variable "subnet_id" {
  type    = list(any)
  default = []
}

variable "vpc_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "loadbalancer_arn_suffix" {
  type    = string
  default = ""
}

variable "hostname" {
  type = string
}

variable "environment" {
  type = string
}

variable "environment_number" {
  type = string
}

variable "listener_arns" {
  type = list(object({
    listener_arn = string
    target_url   = string
  }))
  default = []
}

variable "listeners_count" {
  type    = string
  default = "1"
}

variable "target_port" {
  type = string
}

variable "target_protocol" {
  type = string
}

variable "create_alarm" {
  default = "0"
}

variable "health_check_interval" {
  default = "30"
}

variable "health_check_path" {
  default = "/"
}

variable "health_check_healthy_threshold" {
  default = "2"
}

variable "health_check_unhealthy_threshold" {
  default = "2"
}

variable "health_check_matcher" {
  default = ""
}

locals {
  default_target_url = "${var.app_name}${var.environment_number}.*"
}

variable "on_demand_base_capacity" {
  description = "Absolute minimum amount of desired capacity that must be fulfilled by on-demand instances. Default: 0"
  default     = 0
}

variable "enable_spot" {
  default = false
}

variable "spot_allocation_strategy" {
  description = "How to allocate capacity across the Spot pools. Valid values: lowest-price. Default: lowest-price"
  default     = "lowest-price"
}

variable "spot_instance_pools" {
  description = "Number of Spot pools per availability zone to allocate capacity. EC2 Auto Scaling selects the cheapest Spot pools and evenly allocates Spot capacity across the number of Spot pools that you specify. Default: 1"
  default     = 1
}

variable "instance_security_groups" {
  type = list(string)
}

variable "ebs_optimized" {
  default = false
}

variable "healthy_hosts_evaluation_periods" {
  default = 2
}

variable "healthy_hosts_period" {
  default = 60
}

variable "healthy_hosts_alarm_actions" {
  type    = list(string)
  default = []
}

variable "response_time_evaluation_periods" {
  default = 2
}

variable "response_time_period" {
  default = 60
}

variable "response_time_threshold" {
  default = 500
}

variable "response_time_alarm_actions" {
  type    = list(string)
  default = []
}

variable "errors_5xx_evaluation_periods" {
  default = 2
}

variable "errors_5xx_period" {
  default = 60
}

variable "errors_5xx_threshold" {
  default = 50
}

variable "errors_5xx_alarm_actions" {
  type    = list(string)
  default = []
}

variable "treat_missing_data" {
  default = "missing"
}

variable "extra_listener_arns" {
  type = list(object({
    listener_arn = string
    target_url   = string
    target_path  = string
  }))
  default = []
}

variable "extra_listeners_count" {
  default = 0
}

variable "tags" {
  default = ""
}

variable "credit_specification" {
  default = "standard"
}
