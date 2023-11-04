variable "allocated_storage" {
  type    = string
  default = "20"
}

variable "max_allocated_storage" {
}

variable "ca_cert_identifier" {
  default = "rds-ca-2019"
}

variable "password" {
  type    = string
  default = ""
}

variable "auto_minor_version_upgrade" {
  type    = string
  default = "true"
}

variable "backup_retention_period" {
  type    = string
  default = ""
}

variable "copy_tags_to_snapshot" {
  type    = string
  default = "false"
}

variable "engine_version" {
  type    = string
  default = ""
}

variable "final_snapshot_identifier" {
  type    = string
  default = ""
}

variable "db_identifier" {
  type = string
}

variable "deletion_protection" {
  type    = string
  default = "false"
}

variable "db_subnet_group_name" {
  type = string
}

variable "db_class" {
  type = string
}

variable "monitoring_interval" {
  type    = string
  default = "0"
}

variable "monitoring_role_arn" {
  type    = string
  default = ""
}

variable "multi_az" {
  type    = string
  default = "false"
}

variable "option_group_name" {
  type    = string
  default = ""
}

variable "parameter_group_name" {
  type    = string
  default = ""
}

variable "skip_final_snapshot" {
  type    = string
  default = "false"
}

variable "snapshot_id" {
  type    = string
  default = ""
}

variable "storage_type" {
  type    = string
  default = "gp2"
}

variable "username" {
  type = string
}

variable "db_security_groups" {
  type    = string
  default = ""
}

variable "name_tag" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "workload_type_tag" {
  type    = string
  default = "development"
}

variable "vpc_id" {
  type = string
}

variable "cidr_blocks" {
  type = list(any)
}

variable "security_groups" {
  type    = list(any)
  default = []
}

variable "apply_immediately" {
  type    = bool
  default = false
}