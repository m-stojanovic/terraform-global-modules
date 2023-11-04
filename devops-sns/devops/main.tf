resource "aws_sns_topic" "this" {
  name                        = var.sns_topic_name
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.content_based_deduplication
}

resource "aws_sns_topic_policy" "this" {
  count  = var.create_policy ? 1 : 0
  arn    = aws_sns_topic.this.arn
  policy = try(var.sns_topic_policy, null)
}