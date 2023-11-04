variable "vpc_peering_connection_id" {
  description = "ID of peering connection"
  type        = string
  default     = null
}

variable "peer_owner_id" {
  description = "Account ID of peer"
  type        = string
  default     = null
}

variable "peer_vpc_id" {
  description = "VPC ID of accepter"
  type        = string
  default     = null
}

variable "peer_region" {
  description = "Region of the accepter"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID of requester"
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