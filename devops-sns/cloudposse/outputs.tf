output "sns_topic" {
  value       = module.sns-topic.sns_topic
  description = "SNS topic."
}

output "sns_topic_name" {
  value       = module.sns-topic.sns_topic_name
  description = "SNS topic name."
}

output "sns_topic_id" {
  value       = module.sns-topic.sns_topic_id
  description = "SNS topic ID."
}

output "sns_topic_arn" {
  value       = module.sns-topic.sns_topic_arn
  description = "SNS topic ARN."
}

output "sns_topic_owner" {
  value       = module.sns-topic.sns_topic_owner
  description = "SNS topic owner."
}

output "aws_sns_topic_subscriptions" {
  value       = module.sns-topic.aws_sns_topic_subscriptions
  description = "SNS topic subscription."
}

output "dead_letter_queue_url" {
  description = "The URL for the created dead letter SQS queue."
  value       = module.sns-topic.dead_letter_queue_url
}


output "dead_letter_queue_id" {
  description = "The ID for the created dead letter queue. Same as the URL."
  value       = module.sns-topic.dead_letter_queue_id
}

output "dead_letter_queue_name" {
  description = "The name for the created dead letter queue."
  value       = module.sns-topic.dead_letter_queue_name
}

output "dead_letter_queue_arn" {
  description = "The ARN of the dead letter queue."
  value       = module.sns-topic.dead_letter_queue_arn
}
