variable "create_acl" {
  description = "Create ACL resource"
  type        = string
  default     = false
}

variable "create_logging" {
  description = "Create Bucket logging resource"
  type        = string
  default     = false
}

variable "create_encryption" {
  description = "Create Server side encryption resource"
  type        = string
  default     = false
}

variable "create_versioning" {
  description = "Create Versioning resource"
  type        = string
  default     = false
}

variable "create_lifecycle" {
  description = "Create Lifecycle resource"
  type        = string
  default     = false
}

variable "create_cors" {
  description = "Create CORS resource"
  type        = string
  default     = false
}

variable "create_policy" {
  description = "Create Policy resource"
  type        = string
  default     = false
}

variable "create_notification" {
  description = "Create S3 Notification resource"
  type        = string
  default     = false
}

variable "create_object" {
  description = "Create S3 object resource"
  type        = string
  default     = false
}

variable "bucket" {
  description = "(Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name."
  type        = string
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "acl" {
  description = "The canned ACL to apply. Conflicts with grant"
  type        = string
  default     = null
}

variable "grants" {
  description = "The grant configuration block. Conflits with acl"
  type        = any
  default     = null
}

variable "target_bucket" {
  description = "Logging bucket name"
  type        = string
  default     = null
}

variable "target_prefix" {
  description = "Prefix withing logging bucket where to store logs"
  type        = string
  default     = null
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = false
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = false
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type        = bool
  default     = false
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. Default is aws/s3. Used only with aws:kms"
  type        = string
  default     = null
}

variable "sse_algorithm" {
  description = "SSE Algorithm - AES256 or aws:kms"
  type        = string
  default     = "AES256"
}

variable "versioning" {
  description = "Versioning configuration."
  type        = string
  default     = "Suspended"
}

variable "lifecycle_rules" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = []
}

variable "cors_rules" {
  description = "Cors rules to add."
  type        = any
  default     = ""
}

variable "expected_bucket_owner" {
  description = "The account ID of the expected bucket owner."
  type        = string
}

variable "bucket_policy" {
  description = "The text of the policy."
  type        = string
  default     = ""
}

variable "sqs_notification" {
  description = "The SQS of the policy."
  type        = any
  default     = []
}

variable "object_key" {
  description = "The key for S3 object."
  type        = string
  default     = ""
}

variable "object_content" {
  description = "The content for S3 object"
  type        = any
  default     = []
}

variable "object_sse_algorithm" {
  description = "The Encryption algorithm for S3 object."
  type        = string
  default     = ""
}
