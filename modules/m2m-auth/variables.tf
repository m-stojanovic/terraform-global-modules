variable "project" {
  description = "Project name used for tagging and naming consistency"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "name" {
  description = "Base name for all resources (auth)"
  type        = string
}

variable "services" {
  description = "Map of backend services with path and integration settings"
  type = map(object({
    path_prefix      = string
    integration_uri  = optional(string)
    strip_prefix     = optional(bool, true)
    connection_type  = optional(string, "INTERNET")
    lb_name          = optional(string)
    lb_listener_port = optional(number)
    host_header      = optional(string)
    required_scopes  = optional(list(string), [])
    family           = optional(string)
    methods          = optional(list(string), ["ANY"])
  }))
}

variable "vpc_id" {
  description = "VPC ID used for creating resources for VPC Link"
  type        = string
}

variable "vpc_link_subnet_ids" {
  description = "Private subnet IDs for creating API Gateway VPC Link ENIs"
  type        = list(string)
  default     = []
}

variable "apigw_vpc_link_egress_ports" {
  description = "TCP ports allowed for VPC Link SG egress"
  type        = list(number)
  default     = [443]
}

variable "custom_domains" {
  description = "Map of environments to domain settings (used for custom API Gateway domain)"
  type = map(object({
    domain_name     = string
    hosted_zone_id  = string
    certificate_arn = string
  }))
}

variable "clients" {
  description = "Logical clients to create per service family (internal/external + optional partner clients)"
  type = map(object({
    type               = string
    generate_secret    = bool
    additional_clients = optional(list(string), [])
  }))
  default = {
    internal = {
      type               = "INTERNAL"
      generate_secret    = true
      additional_clients = []
    }
    external = {
      type               = "EXTERNAL"
      generate_secret    = true
      additional_clients = []
    }
  }
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}