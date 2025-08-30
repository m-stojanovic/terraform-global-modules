module "asg" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-asg"

  app_name                      = var.app_name
  name                          = var.hostname
  asg_max                       = var.instance_count
  asg_min                       = var.instance_count
  desired_capacity              = var.instance_count
  spot_instance_pools           = var.spot_instance_pools
  ami                           = var.ami
  aws_iam_instance_profile_name = var.aws_iam_instance_profile_name
  instance_types                = var.instance_types
  subnet_id                     = var.subnet_id
  key_name                      = var.key_name
  vpc_security_group_ids        = var.instance_security_groups
  ebs_optimized                 = var.ebs_optimized
  environment                   = var.environment
  on_demand_base_capacity       = var.on_demand_base_capacity
  enable_spot                   = var.enable_spot
  spot_allocation_strategy      = var.spot_allocation_strategy
  credit_specification          = var.credit_specification
  tags                          = var.tags
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
}

resource "aws_lb_listener_rule" "this_extra" {
  count        = var.extra_listeners_count
  listener_arn = lookup(var.extra_listener_arns[count.index], "listener_arn")
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  condition {
    host_header {
      values = [lookup(var.extra_listener_arns[count.index], "target_url") != "" ? lookup(var.extra_listener_arns[count.index], "target_url") : local.default_target_url]
    }
  }
  condition {
    path_pattern {
      values = [lookup(var.extra_listener_arns[count.index], "target_path")]
    }
  }
}

resource "aws_autoscaling_attachment" "this" {
  autoscaling_group_name = module.asg.id
  lb_target_group_arn    = aws_lb_target_group.this.arn
}
