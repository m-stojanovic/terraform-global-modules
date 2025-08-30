variable "admin_user_username" {
  description = "The master username for the DocumentDB Elastic Cluster, used to connect to the database."
  type        = string
  default     = "dbadmin"
}

variable "environment" {
  description = "The deployment environment name for this DocumentDB cluster."
  type        = string
}

variable "project" {
  description = "Project name to be used on all the resources as identifier"
  type        = string
}

variable "name" {
  description = "The name of the DocumentDB Elastic Cluster"
  type        = string
}

variable "auth_type" {
  description = "The authentication method used for connecting to the Elastic DocumentDB cluster. Set to 'PLAIN_TEXT' for plaintext passwords or 'SECRET_ARN' to retrieve credentials from AWS Secrets Manager."
  type        = string
  default     = "PLAIN_TEXT"
}

variable "shard_capacity" {
  description = "The number of vCPUs assigned to each shard in the DocumentDB Elastic cluster. Allowed values are 2, 4, 8, 16, 32, or 64. Higher values provide more processing power per shard."
  type        = number
  default     = 2
}

variable "shard_count" {
  description = "The number of shards in the DocumentDB Elastic cluster. This affects the overall scalability and capacity of the cluster. Allowed values are between 1 and 32."
  type        = number
  default     = 1
}

variable "preferred_maintenance_window" {
  description = "The weekly time range during which maintenance can be applied to the cluster, in UTC format"
  type        = string
  default     = "Mon:03:00-Mon:04:00"
}

variable "vpc_id" {
  description = "The ID of the VPC in which the DocumentDB Elastic cluster will operate."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR of the VPC in which the DocumentDB Elastic cluster will operate."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet IDs within the VPC where the DocumentDB Elastic cluster instances will be deployed."
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to assign to the DocumentDB Elastic cluster for resource organization and tracking. "
  type        = map(any)
  default     = {}
}

variable "vpn_cidr" {
  description = "The VPN server CIDR to allow."
  type        = string
}

variable "additional_ingress_rules" {
  description = "A list of maps of custom security group ingress rules to apply to the security group"
  default     = []
}
