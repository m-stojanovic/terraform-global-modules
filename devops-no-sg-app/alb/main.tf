module "instance" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-ec2-instance"

  app_name                      = var.app_name
  name                          = var.hostname
  instance_count                = var.instance_count
  ami                           = var.ami
  aws_iam_instance_profile_name = var.aws_iam_instance_profile_name
  instance_type                 = var.instance_type
  subnet_id                     = var.subnet_id
  key_name                      = var.key_name
  vpc_security_group_ids        = var.instance_security_groups
  env_pem                       = var.env_pem
  environment                   = var.environment

  tags = var.tags

}

resource "aws_lb_target_group" "this" {
  name                 = var.hostname
  vpc_id               = var.vpc_id
  port                 = var.target_port
  protocol             = var.target_protocol
  deregistration_delay = var.deregistration_delay

  health_check {
    interval            = var.health_check_interval
    path                = var.health_check_path
    port                = var.target_port
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    timeout             = var.health_check_timeout
    protocol            = var.target_protocol
    matcher             = var.health_check_matcher
  }

  tags = var.tags
}

resource "aws_lb_listener_rule" "this" {
  count        = var.listeners_count
  listener_arn = lookup(var.listener_arns[count.index], "listener_arn")

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = [lookup(var.listener_arns[count.index], "target_url") != "" ? lookup(var.listener_arns[count.index], "target_url") : local.default_target_url]
    }
  }

  tags = var.tags
}

resource "aws_lb_target_group_attachment" "this" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = element(module.instance.id, count.index)
}

resource "aws_route53_record" "app_instance_private" {
  count   = var.instance_count
  zone_id = var.private_zone_id
  name    = "${var.app_name}${var.environment_number}-${format("%02d", count.index + 1)}"
  type    = "A"
  ttl     = "5"
  records = [module.instance.private_ip[count.index]]
}