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

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

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

variable "listener_protocol" {
  description = "The protocol for the Global Accelerator listener"
  type        = string
  default     = "TCP"
}

variable "listener_port" {
  description = "The port for the Global Accelerator listener"
  type        = number
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

variable "endpoint_ids" {
  description = "List of endpoint IDs (e.g., ALB ARNs) to add to the endpoint group"
  type        = list(string)
  default     = []
}

variable "health_check_port" {
  description = "The health check port for the endpoint group"
  type        = number
}

variable "health_check_protocol" {
  description = "The health check protocol for the endpoint group"
  type        = string
}

variable "health_check_path" {
  description = "The health check path for the endpoint group (if HTTP/HTTPS)"
  type        = string
}