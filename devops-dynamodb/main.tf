module "dynamodb-table" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "1.2.2"

  name           = var.name
  hash_key       = var.hash_key
  range_key      = var.range_key
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  billing_mode   = var.billing_mode


  point_in_time_recovery_enabled     = var.point_in_time_recovery_enabled
  attributes                         = var.attributes
  server_side_encryption_enabled     = var.server_side_encryption_enabled
  server_side_encryption_kms_key_arn = var.server_side_encryption_kms_key_arn
  global_secondary_indexes           = var.global_secondary_indexes
  autoscaling_enabled                = var.autoscaling_enabled
  autoscaling_read                   = var.autoscaling_read
  autoscaling_write                  = var.autoscaling_write
  ttl_enabled                        = var.ttl_enabled
  ttl_attribute_name                 = var.ttl_attribute_name

  tags = var.tags
}