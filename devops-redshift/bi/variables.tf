variable "vpc_id" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "name_tag" {
  type = string
}

variable "cidr_blocks" {
  type = list(string)
}

variable "security_groups" {
  type    = list(string)
  default = []
}

variable "cluster_identifier" {
  description = "The Name of the cluster"
}

variable "database_name" {
  description = "The Name of the database"
  default     = "devopsrshiftprod"
}

variable "master_username" {
  description = "The master username to the database"
  default     = "awsuser"
}

variable "master_password" {
  description = "The Master Password"
  default     = ""
}

variable "node_type" {
  description = "Node Type"
  default     = "ra3.4xlarge"
}

variable "cluster_type" {
  description = "multi or single node"
  default     = "multi-node"
}

variable "automated_snapshot_retention_period" {
  description = "How many days to retain the snapshots"
  default     = "10"
}

variable "number_of_nodes" {
  default = "2"
}

variable "publicly_accessible" {
  default = "false"
}

variable "skip_final_snapshot" {
  default = "true"
}

variable "snapshot_identifier" {
  type    = string
  default = ""
}

variable "encrypted" {
  type    = string
  default = "true"
}

variable "kms_key_id" {
  type    = string
  default = ""
}

variable "subnet_group_name" {
  type    = string
  default = ""
}

variable "cluster_parameter_group_name" {
  type    = string
  default = ""
}

variable "extra_security_groups" {
  type    = string
  default = ""
}