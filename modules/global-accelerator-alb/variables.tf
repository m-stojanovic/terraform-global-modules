############ General Vars ############

variable "project" {
  description = "Project name to be used on all the resources as identifier"
  type        = string
}

variable "environment" {
  description = "The deployment environment name"
  type        = string
}

variable "name" {
  description = "Name to be used on resources created"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "instance_ids" {
  description = "List of EC2 instance IDs to register with the target group"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

############ ALB Vars ############

variable "load_balancer_type" {
  description = "Type of load balancer"
  type        = string
  default     = "application"
}

variable "alb_ingress_cidr" {
  description = "CIDR for ALB ingress rule"
  type        = string
  default     = "0.0.0.0/0"
}

variable "alb_egress_cidr" {
  description = "CIDR for ALB egress rule"
  type        = string
  default     = "0.0.0.0/0"
}

variable "listener_port" {
  description = "The port for the ALB listener and Global Accelerator"
  type        = number
}

variable "listener_protocol" {
  description = "The protocol for the ALB listener (HTTP or HTTPS)"
  type        = string
  default     = "HTTPS"
  validation {
    condition     = contains(["HTTP", "HTTPS"], var.listener_protocol)
    error_message = "Listener protocol must be HTTP or HTTPS."
  }
}

variable "certificate_arn" {
  description = "The ARN of the certificate for HTTPS listener (required if listener_protocol is HTTPS)"
  type        = string
  default     = null
}

variable "target_port" {
  description = "The port on the targets (EC2 instances)"
  type        = number
}

variable "target_protocol" {
  description = "The protocol for the target group (HTTP or HTTPS)"
  type        = string
  validation {
    condition     = contains(["HTTP", "HTTPS"], var.target_protocol)
    error_message = "Target protocol must be HTTP or HTTPS."
  }
}

variable "target_type" {
  description = "The type of target for the target group"
  type        = string
}

variable "health_check_path" {
  description = "The health check path for the target group and endpoint group"
  type        = string
}

variable "health_check_enabled" {
  description = "Whether health checks are enabled"
  type        = bool
  default     = true
}

variable "health_check_interval" {
  description = "The interval for health checks in seconds"
  type        = number
  default     = 30
}

variable "healthy_threshold" {
  description = "The number of consecutive health checks successes required before considering an unhealthy target healthy"
  type        = number
  default     = 5
}

variable "unhealthy_threshold" {
  description = "The number of consecutive health check failures required before considering a healthy target unhealthy"
  type        = number
  default     = 2
}

variable "health_check_timeout" {
  description = "The amount of time, in seconds, during which no response means a failed health check"
  type        = number
  default     = 5
}

variable "health_check_matcher" {
  description = "The HTTP codes to use when checking for a successful response from a target"
  type        = string
  default     = "200"
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection on the ALB"
  type        = bool
  default     = false
}

variable "additional_alb_ingress_rules" {
  description = "Additional ingress rules for the ALB security group"
  type        = list(any)
  default     = []
}

variable "additional_alb_egress_rules" {
  description = "Additional egress rules for the ALB security group"
  type        = list(any)
  default     = []
}

############ GA Vars ############

variable "ip_address_type" {
  description = "The IP address type for the Global Accelerator"
  type        = string
  default     = "IPV4"
}

variable "accelerator_enabled" {
  description = "Whether the Global Accelerator is enabled"
  type        = bool
  default     = true
}

variable "client_affinity" {
  description = "The client affinity for the Global Accelerator listener"
  type        = string
  default     = "NONE"
}

variable "ga_listener_protocol" {
  description = "The protocol for the Global Accelerator listener"
  type        = string
  default     = "TCP"
}

variable "endpoint_weight" {
  description = "The weight for the endpoint configuration"
  type        = number
  default     = 100
}

variable "client_ip_preservation_enabled" {
  description = "Whether client IP preservation is enabled for the endpoint"
  type        = bool
  default     = true
}