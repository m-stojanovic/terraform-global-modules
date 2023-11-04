variable "vpc_peering_connection_id" {
  description = "ID of peering connection"
  type        = string
  default     = null
}

variable "name" {
  description = "Name to be added in tags"
  type        = string
  default     = null
}

variable "destination_cidr_block" {
  description = "Destination cidr block"
  type        = string
  default     = null
}

variable "route_table_ids" {
  description = "List of route table ids"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to security group"
  type        = map(string)
  default     = {}
}