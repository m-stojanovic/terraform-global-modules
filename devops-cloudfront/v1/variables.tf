
variable "s3_target" {
  type = string
  default = ""
}

variable "cf_description" {
  type = string
  default = ""
}

variable "cf_priceclass" {
  type = string
  default = "PriceClass_100"
}

variable "cf_alternate_domains" {
  type = list
  default = []
}

variable "cf_protocol_ploicy" {
  type = string
  default = ""
}

variable "acm_cert_arn" {
  type = string
  default = ""
}