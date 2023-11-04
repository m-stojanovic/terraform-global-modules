variable "vpc_id" {
  description = "VPC ID needed for target groups"
  default     = null
}

variable "aws_region" {
  description = "AWS region, made it mandatory as we use it for S3 logging bucket name distinction."
  default     = null
}

variable "name" {
  description = "The name of the LB. This name must be unique within your AWS account. Made it mandatory as we use it for S3 logging bucket name distination."
  default     = null
}

variable "internal" {
  description = "If true, the LB will be internal."
  default     = null
}

variable "load_balancer_type" {
  description = "The type of load balancer to create. Possible values are application, gateway, or network."
  default     = null
}

variable "security_groups" {
  description = "A list of security group IDs to assign to the LB. Only valid for Load Balancers of type application."
  default     = null
}

variable "drop_invalid_header_fields" {
  description = "Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false)."
  default     = null
}

variable "subnets" {
  description = "A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type network. Changing this value for load balancers of type network will force a recreation of the resource."
  default     = null
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60."
  default     = null
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  default     = null
}

variable "enable_cross_zone_load_balancing" {
  description = "If true, cross-zone load balancing of the load balancer will be enabled. This is a network load balancer feature. Defaults to false."
  default     = null
}

variable "enable_http2" {
  description = "Indicates whether HTTP/2 is enabled in application load balancers. Defaults to true."
  default     = null
}

variable "enable_waf_fail_open" {
  description = "Indicates whether to allow a WAF-enabled load balancer to route requests to targets if it is unable to forward the request to AWS WAF. Defaults to false."
  default     = null
}

variable "customer_owned_ipv4_pool" {
  description = "The ID of the customer owned ipv4 pool to use for this load balancer."
  default     = null
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack."
  default     = null
}

variable "desync_mitigation_mode" {
  description = "Determines how the load balancer handles requests that might pose a security risk to an application due to HTTP desync. Valid values are monitor, defensive (default), strictest."
  default     = null
}

variable "subnet_mappings" {
  description = "Subnet Mapping (subnet_mapping) blocks."
  default     = null
}

variable "listeners" {
  description = "Data map which defines one or more listeners for LB. For more info on usage and map structure check readme file, for more details on available arguments visit https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener"
  default     = null
}

variable "target_groups" {
  description = "Data map which defines one or more target groups for LB. For more info on usage and map structure check readme file, for more details on available arguments visit https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group"
  default     = null
}

variable "target_group_attachments" {
  description = "Data map which defines one or more target group attachments for LB. For more info on usage and map structure check readme file, for more details on available arguments visit https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment"
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the resource. Made 'ts:env' tag mandatory as we use it for S3 logging bucket name distinction."
  default     = null
}

variable "instance_ids" {
  description = "Use this if you intend to target an instance id from another module."
  default     = null
}

variable "enable_logging" {
  description = "Set this to true to enable logging for Load Balancer. In case you want to set it disabled, keep it at null."
  default     = null
}