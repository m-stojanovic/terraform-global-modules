variable "instance_type" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "env_pem" {
  type = string
}

variable "ami" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "key_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "hostname" {
  type = string
}

variable "full_access_cidrs" {
  type = list(string)
}

variable "tags" {
  type = any
}

variable "private_zone_id" {
  type = string
}