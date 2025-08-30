variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable "project" {
  description = "Project name"
  type        = string    
}

variable "env" {
  description = "Environment name"
  type        = string  
}

variable "subnet_ids" {
  default = []
}

variable "vpc_security_group_ids" {
  description = "A list of security group IDs to associate with."
  default     = []
}

variable "ingress_with_cidr_blocks" {
  default = []
}

variable "name" {
  description = "The Name of the cluster."
}

variable "database_name" {
  description = "The Name of the database."
  default     = "devopsrshiftprod"
}

variable "master_username" {
  description = "The master username to the database."
  default     = "awsuser"
}

variable "node_type" {
  description = "Node Type."
  default     = "ds2.xlarge"
}

variable "cluster_type" {
  description = "multi or single node."
  default     = "multi-node"
}

variable "automated_snapshot_retention_period" {
  description = "How many days to retain the snapshots."
  default     = "10"
}

variable "number_of_nodes" {
  default = "2"
}

variable "publicly_accessible" {
  default = false
}

variable "skip_final_snapshot" {
  default = true
}
variable "environment" {
  type = string
}

variable "subnet_group_name" {
  type = string
}
variable "full_access_cidrs" {}
