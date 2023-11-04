variable "app_name" {
  type = string
}

variable "instance_count" {}

variable "instance_type" {
  type = string
}

variable "aws_iam_instance_profile_name" {
  type = string
}

variable "instance_security_groups" {
  type = list(string)
}

variable "private_zone_id" {
  type = string
}

variable "env_pem" {
  type = string
}

variable "ami" {
  type = string
}

variable "subnet_id" {
  default = []
}

variable "vpc_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "environment_number" {}

variable "hostname" {
  type = string
}

variable "environment" {
  type = string
}

variable "listener_arns" {
  type = list(object({
    listener_arn = string
    target_url   = string
  }))
  default = []
}

variable "target_port" {
  type = string
}

variable "target_protocol" {
  type = string
}

variable "listeners_count" {
  default = 1
}

variable "health_check_interval" {
  default = 30
}

variable "health_check_path" {
  default = ""
}

variable "health_check_healthy_threshold" {
  default = 2
}

variable "health_check_unhealthy_threshold" {
  default = 2
}

variable "health_check_timeout" {
  default = 5
}

variable "health_check_matcher" {
  default = ""
}

variable "deregistration_delay" {
  default = 30
}

variable "tags" {}

locals {
  default_target_url = "${var.app_name}${var.environment_number}.*"
}