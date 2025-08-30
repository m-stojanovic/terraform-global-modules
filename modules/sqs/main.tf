resource "aws_sqs_queue" "this" {
  name                      = "${var.project}-${var.env}-${var.name}"
  policy                    = var.create_policy ? file("${path.module}/policies/policy.json") : null
  delay_seconds             = try(var.delay_seconds, null)
  message_retention_seconds = try(var.message_retention_seconds, null)
  max_message_size          = try(var.max_message_size, null)
}

resource "aws_sqs_queue_policy" "this" {
  count     = var.create_policy ? 1 : 0
  queue_url = aws_sqs_queue.this.id
  policy    = try(var.sqs_queue_policy, null)
}
