resource "aws_cloudwatch_metric_alarm" "target_group_healthy_hosts" {
  count = var.create_alarm ? 1 : 0

  alarm_name          = "${aws_lb_target_group.this.name}-healthy-hosts"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.healthy_hosts_evaluation_periods
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.healthy_hosts_period
  statistic           = "Maximum"
  threshold           = var.instance_count
  alarm_actions       = var.healthy_hosts_alarm_actions
  alarm_description   = "This metric monitors the number of healthy hosts for Target Group ${aws_lb_target_group.this.name}"
  ok_actions          = var.healthy_hosts_alarm_actions
  treat_missing_data  = var.treat_missing_data

  dimensions = {
    TargetGroup  = aws_lb_target_group.this.arn_suffix
    LoadBalancer = var.loadbalancer_arn_suffix
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "target_group_response_time" {
  count = var.create_alarm ? 1 : 0

  alarm_name          = "${aws_lb_target_group.this.name}-response-time"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.response_time_evaluation_periods
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = var.response_time_period
  statistic           = "Average"
  threshold           = var.response_time_threshold
  alarm_actions       = var.response_time_alarm_actions
  alarm_description   = "This metric monitors the response time of the servers in Target Group ${aws_lb_target_group.this.name}"
  ok_actions          = var.response_time_alarm_actions
  treat_missing_data  = var.treat_missing_data

  dimensions = {
    TargetGroup  = aws_lb_target_group.this.arn_suffix
    LoadBalancer = var.loadbalancer_arn_suffix
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "target_group_errors_5xx" {
  count = var.create_alarm ? 1 : 0

  alarm_name          = "${aws_lb_target_group.this.name}-5xx-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.errors_5xx_evaluation_periods
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = var.errors_5xx_period
  statistic           = "Sum"
  threshold           = var.errors_5xx_threshold
  alarm_actions       = var.errors_5xx_alarm_actions
  alarm_description   = "This metric monitors the number of 5xx errors of the servers in Target Group ${aws_lb_target_group.this.name}"
  ok_actions          = var.errors_5xx_alarm_actions
  treat_missing_data  = var.treat_missing_data

  dimensions = {
    TargetGroup  = aws_lb_target_group.this.arn_suffix
    LoadBalancer = var.loadbalancer_arn_suffix
  }

  tags = var.tags
}