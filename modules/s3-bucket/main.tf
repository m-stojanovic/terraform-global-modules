module "s3-bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.0.1"

  bucket = var.bucket

  force_destroy       = var.force_destroy
  acceleration_status = var.acceleration_status
  request_payer       = var.request_payer

  tags = var.tags

  # Note: Object Lock configuration can be enabled only on new buckets
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object_lock_configuration
  object_lock_configuration = var.object_lock_configuration

  attach_elb_log_delivery_policy = var.attach_elb_log_delivery_policy

  # Bucket policies
  attach_policy                         = var.attach_policy
  policy                                = var.policy
  attach_deny_insecure_transport_policy = var.attach_deny_insecure_transport_policy
  attach_require_latest_tls_policy      = var.attach_require_latest_tls_policy

  # S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # S3 Bucket Ownership Controls
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls
  control_object_ownership = var.control_object_ownership
  object_ownership         = var.object_ownership
  expected_bucket_owner    = var.expected_bucket_owner

  acl                                  = var.acl # "acl" conflicts with "grant" and "owner"
  logging                              = var.logging
  versioning                           = var.versioning
  website                              = var.website
  server_side_encryption_configuration = var.server_side_encryption_configuration
  attach_lb_log_delivery_policy        = var.attach_lb_log_delivery_policy
  cors_rule                            = var.cors_rule
  lifecycle_rule                       = var.lifecycle_rule
}
