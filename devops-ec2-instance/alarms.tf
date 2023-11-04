resource "aws_cloudwatch_metric_alarm" "this" {
  count               = var.create_high_cpu_alarm ? var.alarm_count : 0
  alarm_name          = "${var.name}-${format("%02d", count.index + 1)}-cpu-usage"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "600"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "This metric monitors the cpu usage of ${var.name}-${format("%02d", count.index + 1)}"
  treat_missing_data  = "breaching"
  alarm_actions       = ["arn:aws:sns:eu-west-1:123456789876:VictorOps"]
  ok_actions          = ["arn:aws:sns:eu-west-1:123456789876:VictorOps"]

  dimensions = {
    InstanceId = element(aws_instance.this.*.id, count.index)
  }
}