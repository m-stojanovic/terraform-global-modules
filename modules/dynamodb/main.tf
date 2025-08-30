module "dynamodb" {
  source         = "terraform-aws-modules/dynamodb-table/aws"
  version        = "4.3.0"
  name           = var.name
  hash_key       = var.hash_key
  range_key      = var.range_key
  billing_mode   = var.billing_mode
  table_class    = var.table_class
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity

  deletion_protection_enabled = var.deletion_protection_enabled
  resource_policy             = var.resource_policy

  # encryption
  server_side_encryption_enabled     = var.server_side_encryption_enabled
  server_side_encryption_kms_key_arn = var.server_side_encryption_kms_key_arn

  # dynamic blocks
  attributes               = var.attributes
  global_secondary_indexes = var.global_secondary_indexes
  local_secondary_indexes  = var.local_secondary_indexes
  replica_regions          = var.replica_regions
  on_demand_throughput     = var.on_demand_throughput

  # stream 
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_view_type

  # ttl
  ttl_enabled        = var.ttl_enabled
  ttl_attribute_name = var.ttl_attribute_name

  # autoscaling
  autoscaling_enabled                   = var.autoscaling_enabled
  ignore_changes_global_secondary_index = var.ignore_changes_global_secondary_index
  autoscaling_read                      = var.autoscaling_read
  autoscaling_write                     = var.autoscaling_write
  autoscaling_indexes                   = var.autoscaling_indexes

  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "data_storage", "${var.project}:ModuleName" = "dynamodb" }))
}
