resource "aws_cloudwatch_metric_alarm" "this_healthy_hosts" {
  count = var.create_alarm ? 1 : 0

  alarm_name          = "${var.name}-lb-healthy-hosts"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Maximum"
  threshold           = var.healthy_host_threshold
  datapoints_to_alarm = var.healthy_host_datapoints_to_alarm

  dimensions = {
    TargetGroup  = aws_lb_target_group.this.arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_description         = "This metric monitors the number of healthy hosts for targetgroup ${aws_lb_target_group.this.name}"
  treat_missing_data        = "missing"
  alarm_actions             = ["arn:aws:sns:eu-west-1:123456789876:VictorOps"]
  ok_actions                = ["arn:aws:sns:eu-west-1:123456789876:VictorOps"]
  insufficient_data_actions = ["arn:aws:sns:eu-west-1:123456789876:VictorOps"]
}

resource "aws_cloudwatch_metric_alarm" "this_5xx_errors" {
  count = var.create_alarm ? 1 : 0

  alarm_name          = "${var.name}-lb-5xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = var.err_5xx_count_threshold
  datapoints_to_alarm = var.err_5xx_count_datapoints_to_alarm

  dimensions = {
    TargetGroup  = aws_lb_target_group.this.arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_description         = "This metric monitors the number of 5XX errors for targetgroup ${aws_lb_target_group.this.name}"
  treat_missing_data        = "missing"
  alarm_actions             = ["arn:aws:sns:eu-west-1:123456789876:VictorOps"]
  ok_actions                = ["arn:aws:sns:eu-west-1:123456789876:VictorOps"]
  insufficient_data_actions = ["arn:aws:sns:eu-west-1:123456789876:VictorOps"]
}

resource "aws_cloudwatch_metric_alarm" "this_taget_connection_error_count" {
  count = var.create_alarm ? 1 : 0

  alarm_name          = "${var.name}-lb-target-connection-error-count"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "TargetConnectionErrorCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"
  threshold           = var.target_connection_error_count_threshold
  datapoints_to_alarm = var.target_connection_error_count_datapoints_to_alarm

  dimensions = {
    TargetGroup  = aws_lb_target_group.this.arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_description         = "This metric monitors the number of target connection errors for targetgroup ${aws_lb_target_group.this.name}"
  treat_missing_data        = "missing"
  alarm_actions             = ["arn:aws:sns:eu-west-1:123456789876:VictorOps"]
  ok_actions                = ["arn:aws:sns:eu-west-1:123456789876:VictorOps"]
  insufficient_data_actions = ["arn:aws:sns:eu-west-1:123456789876:VictorOps"]
}
