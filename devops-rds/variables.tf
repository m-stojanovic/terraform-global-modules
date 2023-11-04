variable "vpc_id" {}
variable "vpc_cidr" {}
variable "subnet_ids" {}
variable "db_identifier" {}
variable "db_name" {}
variable "db_port" {}
variable "allocated_storage" {}
variable "db_class" {}
variable "option_group_name" {}
variable "tags" {}
variable "engine_version" {}
variable "engine" {}
variable "multi_az" {}
variable "username" {}
variable "parameter_group_name" {}
variable "license_model" {}
variable "copy_tags_to_snapshot" {
  default = true
}
variable "enabled_cloudwatch_logs_exports" {
  default = []
}
variable "create_parameter_group" {
  default = false
}
variable "db_parameter_group_name" {
  default = ""
}
variable "family" {
  default = ""
}
variable "parameters" {
  type = list(object({
    name         = string
    value        = string
    apply_method = string
  }))
  default = []
}
variable "deletion_protection" {
  default = false
}
variable "customer_owned_ip_enabled" {
  default = false
}
variable "iam_database_authentication_enabled" {
  default = false
}
variable "storage_encrypted" {
  default = false
}
variable "iops" {
  default = null
}
variable "snapshot_id" {
  default = ""
}
variable "auto_minor_version_upgrade" {
  default = false
}
variable "monitoring_interval" {
  default = 0
}
variable "monitoring_role_arn" {
  default = ""
}
variable "performance_insights_enabled" {
  default = true
}
variable "allow_cidr" {
  default = []
}

variable "office_private_cidr" {
  default = []
}

variable "manage_master_user_password" {
  default = false
}