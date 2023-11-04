
variable "access_logs_bucket" {
  type    = string
  default = "logs.devops.co.uk"
}

variable "access_logs_prefix" {
  type = string
}

variable "access_logs_enable" {
  type    = string
  default = "true"
}

variable "listener_ssl_policy" {
  default = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "devops_cert" {
  type    = string
  default = "arn:aws:acm:eu-west-1:123456789876:certificate/922e077d-c7b1-49bd-9e57-9e993461a892"
}

variable "livingsocial_cert" {
  type    = string
  default = "arn:aws:acm:eu-west-1:123456789876:certificate/5a0714f0-8684-4711-84ed-cff5c3fc25b3"
}

variable "livingsocialie_cert" {
  type    = string
  default = "arn:aws:acm:eu-west-1:123456789876:certificate/2bb1ebd8-3141-48fd-94f6-2cc35fccd6ab"
}

variable "alb_name" {
  type = string
}

variable "subnets_id" {
  type = list(string)
}

variable "is_internal" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "environment" {
  type = string
}

variable "full_access_cidrs" {
  type    = list(string)
  default = []
}

variable "ingress_with_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "additional_sgs" {
  type    = list(string)
  default = []
}

# variable "allow_all_443" {
#   default = false
# }

variable "allow_all_80" {
  default = false
}

variable "create_aws_security_group" {
  default = true
}

variable "tags" {}