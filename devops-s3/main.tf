resource "aws_s3_bucket" "this" {
  bucket = var.bucket
  tags   = var.tags
}

resource "aws_s3_bucket_acl" "this" {
  count  = var.create_acl ? 1 : 0
  bucket = aws_s3_bucket.this.id
  acl    = var.acl == "null" ? null : var.acl

  dynamic "access_control_policy" {
    for_each = length(var.grants) > 0 ? [true] : []

    content {
      dynamic "grant" {
        for_each = var.grants

        content {
          permission = grant.value.permission

          grantee {
            type          = grant.value.type
            id            = try(grant.value.id, null)
            uri           = try(grant.value.uri, null)
            email_address = try(grant.value.email, null)
          }
        }
      }

      owner {
        id           = data.aws_canonical_user_id.this.id
        display_name = null
      }
    }
  }
}
data "aws_canonical_user_id" "this" {}

resource "aws_s3_bucket_logging" "this" {
  count  = var.create_logging ? 1 : 0
  bucket = aws_s3_bucket.this.id
  # target_bucket = var.target_bucket
  # target_prefix = var.target_prefix
  target_bucket = try(var.target_bucket, null)
  target_prefix = try(var.target_prefix, null)
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count  = var.create_encryption ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_master_key_id
      sse_algorithm     = var.sse_algorithm
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.create_versioning ? 1 : 0
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count  = var.create_lifecycle ? 1 : 0
  bucket = aws_s3_bucket.this.id
  dynamic "rule" {
    for_each = var.lifecycle_rules
    content {
      id     = try(rule.value.id, null)
      status = try(rule.value.enabled ? "Enabled" : "Disabled", tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)))
      dynamic "expiration" {
        for_each = try(flatten([rule.value.expiration]), [])
        content {
          date                         = try(expiration.value.date, null)
          days                         = try(expiration.value.days, null)
          expired_object_delete_marker = try(expiration.value.expired_object_delete_marker, null)
        }
      }
      dynamic "transition" {
        for_each = try(flatten([rule.value.transition]), [])

        content {
          date          = try(transition.value.date, null)
          days          = try(transition.value.days, null)
          storage_class = transition.value.storage_class
        }
      }
      dynamic "filter" {
        for_each = try(flatten([rule.value.filter]), [])

        content {
          prefix = try(filter.value.prefix, null)
        }
      }
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "this" {
  count = var.create_cors ? 1 : 0

  bucket                = aws_s3_bucket.this.id
  expected_bucket_owner = try(var.expected_bucket_owner, null)

  dynamic "cors_rule" {
    for_each = var.cors_rules

    content {
      id              = try(cors_rule.value.id, null)
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      allowed_headers = try(cors_rule.value.allowed_headers, null)
      expose_headers  = try(cors_rule.value.expose_headers, null)
      max_age_seconds = try(cors_rule.value.max_age_seconds, null)
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = var.create_policy ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = try(var.bucket_policy, null)
}

resource "aws_s3_bucket_notification" "this" {
  count  = var.create_notification ? 1 : 0
  bucket = aws_s3_bucket.this.id
  #eventbridge = var.eventbridge

  dynamic "queue" {
    for_each = var.sqs_notification

    content {
      id            = try(queue.value.id, null)
      queue_arn     = queue.value.queue_arn
      events        = queue.value.events
      filter_prefix = try(queue.value.filter_prefix, null)
      filter_suffix = try(queue.value.filter_suffix, null)
    }
  }

  # dynamic "topic" {
  #   for_each = var.sns_notifications

  #   content {
  #     id            = topic.key
  #     topic_arn     = topic.value.topic_arn
  #     events        = topic.value.events
  #     filter_prefix = try(topic.value.filter_prefix, null)
  #     filter_suffix = try(topic.value.filter_suffix, null)
  #   }
  # }
  # dynamic "lambda_function" {
  #   for_each = var.lambda_notifications

  #   content {
  #     id                  = lambda_function.key
  #     lambda_function_arn = lambda_function.value.function_arn
  #     events              = lambda_function.value.events
  #     filter_prefix       = try(lambda_function.value.filter_prefix, null)
  #     filter_suffix       = try(lambda_function.value.filter_suffix, null)
  #   }
  # }
  # depends_on = [
  #   module.aws_sqs_queue_policy.this,
  #   module.aws_sns_topic_policy.this,
  #]
}

resource "aws_s3_object" "this" {
  count = var.create_object ? 1 : 0

  key                    = try(var.object_key, null)
  bucket                 = aws_s3_bucket.this.id
  content                = try(var.object_content, null)
  server_side_encryption = try(var.object_sse_algorithm, null)
}