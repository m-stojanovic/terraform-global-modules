module "cloudwatch-events" {
  source  = "clouddrove/cloudwatch-event-rule/aws"
  version = "1.0.1"

  name           = "${var.project}-${var.environment}-${var.name}"
  description    = var.description
  event_pattern  = var.event_pattern
  target_id      = var.target_id
  arn            = var.arn
  input_template = var.input_template
  input_paths    = var.input_paths
}
