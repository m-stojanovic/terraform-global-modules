variable "public_zone_id" {
  type        = string
  description = "The ID of the public zone"
}

variable "lsuk_r53_enable" {
  type    = bool
  default = false
}

variable "lsie_r53_enable" {
  type    = bool
  default = false  
}

variable "devops_r53_enable" {
  type    = bool
  default = true
}

variable "ls_public_zone_id" {
  type        = string
  default     = ""
  description = "The ID of the LS UK public zone"
}

variable "lsie_public_zone_id" {
  type        = string
  default     = ""
  description = "The ID of the LS IE public zone"
}

variable "app_name" {
  type        = string
  description = "The name of the application"
}

variable "environment_number" {
  type        = string
  description = "The number of the environment"
}

variable "lb_dns_name" {
  type        = string
  description = "The DNS name of the target Load Balancer"
}

variable "devops_cf_enable" {
  type        = bool
  default     = false
  description = "Whether to create a cloudflare record or not"
}

variable "lsuk_cf_enable" {
  type        = bool
  default     = false
  description = "Whether to create a cloudflare record or not for LS UK"
}

variable "lsie_cf_enable" {
  type        = bool
  default     = false
  description = "Whether to create a cloudflare record or not for LS IE"
}

variable "devops_zone_id" {
  type        = string
  default     = ""
  description = "The zone_id of the domain for devops"
}

variable "lsuk_zone_id" {
  type        = string
  default     = ""
  description = "The zone_id for LS UK"
}

variable "lsie_zone_id" {
  type        = string
  default     = ""
  description = "The zone_id for LS IE"
}

variable "proxy_enable" {
  type        = bool
  default     = false
  description = "Whether to enable proxying in cloudflare"
}