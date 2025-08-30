variable "project" {
  description = "The name of the project to which this OpenSearch cluster belongs."
  type        = string
}

variable "environment" {
  description = "The deployment environment name for this OpenSearch cluster."
  type        = string
}

variable "domain_name" {
  type        = string
  description = "The name of the OpenSearch domain to create."
}

variable "instance_type" {
  type        = string
  default     = "t3.medium.search"
  description = "The instance type to use for data nodes in the OpenSearch domain."
}

variable "instance_count" {
  type        = number
  default     = 1
  description = "The number of data nodes to deploy in the OpenSearch cluster."
}

variable "volume_size" {
  type        = number
  default     = 60
  description = "The size (in GB) of the EBS volumes attached to OpenSearch nodes."
}

variable "master_user_name" {
  type        = string
  description = "Username for the internal OpenSearch Dashboard authentication."
}

variable "dedicated_master_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable dedicated master nodes for the OpenSearch cluster. Recommended for clusters with 3 or more data nodes to improve stability and cluster coordination."
}

variable "zone_awareness_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable zone awareness for high availability across multiple Availability Zones. Requires at least two subnets in different AZs."
}

variable "log_publishing_options" {
  type        = any
  default     = {}
  description = "Configuration block for publishing OpenSearch logs (search, index, application) to CloudWatch Logs. Supports multiple log types."
}

variable "auto_tune_desired_state" {
  description = "Enable or disable Auto-Tune for OpenSearch"
  type        = string
  default     = "DISABLED"
}

variable "access_policies" {
  type        = string
  description = "Optional resource-based access policy for OpenSearch domain"
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}