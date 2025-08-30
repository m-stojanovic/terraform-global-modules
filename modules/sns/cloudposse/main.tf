module "sns-topic" {
  source  = "cloudposse/sns-topic/aws"
  version = "0.20.1"

  name                                   = var.name
  delivery_policy                        = var.delivery_policy
  subscribers                            = var.subscribers
  sns_topic_policy_json                  = var.sns_topic_policy_json
  allowed_aws_services_for_sns_published = var.allowed_aws_services_for_sns_published
  kms_master_key_id                      = var.kms_master_key_id

  tags = var.tags

}
