################################################################################
# General
################################################################################

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "The deployment environment name for this Kafka cluster."
  type        = string
}

variable "project" {
  description = "The name of the project to which this Kafka cluster belongs."
  type        = string
}

variable "name" {
  description = "The name of the Kafka cluster."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where to create the Security group"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC to allow in the Security group"
  type        = string
}

variable "vpn_private" {
  description = "The CIDR block of the VPN to allow in the Security group"
  type        = string
}

################################################################################
# Cluster
################################################################################

variable "additional_ingress_rules" {
  description = "A list of maps of custom security group ingress rules to apply to the Security Group"
  default     = []
}

variable "additional_egress_rules" {
  description = "A list of maps of custom security group egress rules to apply to the Security Group"
  default     = []
}

variable "number_of_broker_nodes" {
  description = "The number of broker nodes in the MSK cluster."
  type        = number
}

variable "kafka_version" {
  description = "The version of Apache Kafka to use for the MSK cluster."
  type        = string
}

variable "broker_node_instance_type" {
  description = "The instance type to use for the Kafka brokers"
  type        = string
}

variable "broker_node_client_subnets" {
  description = "A list of subnets to place the MSK broker nodes in."
  type        = list(string)
}

################################################################################
# Configuration properties
################################################################################

variable "configuration_server_properties" {
  description = "Contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html)"
  type        = map(string)
  default     = {}
}

variable "configuration_description" {
  description = "Description of the configuration"
  type        = string
  default     = null
}

################################################################################
# Storage
################################################################################

variable "enable_storage_autoscaling" {
  description = "Determines whether autoscaling is enabled for storage"
  type        = bool
  default     = false
}

variable "volume_size" {
  type        = number
  default     = 64
  description = "The size in GB of the EBS volume for the data drive on each broker node"
}

################################################################################
# Monitoring
################################################################################

variable "cloudwatch_log_group_retention_in_days" {
  description = "Specifies the number of days you want to retain log events in the log group"
  type        = number
  default     = 180
}

################################################################################
# Glue Schema Registry & Schema
################################################################################

variable "create_schema_registry" {
  description = "Determines whether to create a Glue schema registry for managing Avro schemas for the cluster"
  type        = bool
  default     = false
}

variable "schema_registries" {
  description = "A map of schema registries to be created"
  type        = map(any)
  default     = {}
}

variable "schemas" {
  description = "A map schemas to be created within the schema registry"
  type        = map(any)
  default     = {}
}
