resource "aws_cloudwatch_log_group" "this" {
  count             = var.cloudwatch_logs_enabled ? 1 : 0
  name              = "/ecs/${var.project}-${var.environment}-${var.name}"
  retention_in_days = "7"
}

resource "aws_ecs_service" "this" {
  name            = "${var.project}-${var.environment}-${var.name}"
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn

  desired_count    = var.desired_count
  platform_version = var.ecs_platform_version

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    security_groups = var.security_groups
    subnets         = var.private_subnets
  }

  deployment_controller {
    type = var.deployment_controller_type
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  tags = {
    Name        = var.container_name
    Environment = var.environment
    Service     = var.container_name
  }

  capacity_provider_strategy {
    capacity_provider = var.capacity_provider
    weight            = 100
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project}-${var.environment}-${var.name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  task_role_arn            = var.task_execution_role_arn
  execution_role_arn       = var.task_execution_role_arn

  dynamic "volume" {
    for_each = var.efs_volume_id != null ? [1] : []
    content {
      name = "${var.project}-${var.environment}-${var.name}-efs"
      efs_volume_configuration {
        file_system_id = var.efs_volume_id
      }
    }
  }

  container_definitions = jsonencode([
    {
      environment = []
      cpu         = 0
      essential   = true
      image       = var.fluentbit_image
      name        = "log_router"
      firelensConfiguration = {
        type = "fluentbit"
        options = {
          config-file-type  = "file"
          config-file-value = "/extra.conf"
        }
      }
      mountPoints  = []
      portMappings = []
      user         = "0"
      volumesFrom  = []
      healthCheck = {
        retries     = var.healthcheck_retries
        command     = local.healthcheck_fluentbit_commands
        timeout     = var.healthcheck_timeout
        interval    = var.healthcheck_interval
        startPeriod = var.healthcheck_start_period
      }

    },
    {
      name              = var.container_name
      image             = "${var.image_name}:${var.image_tag}"
      cpu               = var.container_cpu
      memory            = var.container_memory
      memoryReservation = var.container_memory_reservation
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      essential              = false
      entryPoint             = var.container_entry_points
      command                = var.container_commands
      environment            = var.environment_variables
      mountPoints            = var.mount_points
      volumesFrom            = var.volumes_from
      secrets                = var.secrets
      dependsOn              = var.ecs_depends_on
      disableNetworking      = false
      readonlyRootFilesystem = false
      dnsServers             = var.dns_servers
      dependsOn              = []
      dnsSearchDomains       = var.dns_search_domains
      extraHosts             = var.extra_hosts
      interactive            = false
      pseudoTerminal         = false
      dockerLabels = {
        appname = "${var.project}-${var.environment}-${var.name}"
      }
      ulimits = var.ulimits
      logConfiguration = {
        logDriver = var.cloudwatch_logs_enabled ? "awslogs" : "awsfirelens"
        options   = local.log_options
      }
      healthCheck = length(local.healthcheck_commands) > 0 ? {
        retries     = var.healthcheck_retries
        command     = local.healthcheck_commands
        timeout     = var.healthcheck_timeout
        interval    = var.healthcheck_interval
        startPeriod = var.healthcheck_start_period
        } : (var.healthcheck_custom_commands != null ? {
          retries     = var.healthcheck_retries
          command     = var.healthcheck_custom_commands
          timeout     = var.healthcheck_timeout
          interval    = var.healthcheck_interval
          startPeriod = var.healthcheck_start_period
      } : null)
    }
  ])
}

resource "aws_appautoscaling_target" "this" {
  count              = var.enable_autoscaling ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  role_arn           = var.ecs_autoscaling_role_arn
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "this_target_tracking_scaling" {
  count = var.enable_autoscaling ? length(var.target_tracking_policy) : 0

  name               = lookup(var.target_tracking_policy[count.index], "name", "")
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  policy_type        = "TargetTrackingScaling"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    target_value = lookup(var.target_tracking_policy[count.index], "target_value", 90)
    disable_scale_in = lookup(
      var.target_tracking_policy[count.index],
      "disable_scale_in",
      false,
    )
    scale_in_cooldown = lookup(
      var.target_tracking_policy[count.index],
      "scale_in_cooldown",
      0,
    )
    scale_out_cooldown = lookup(
      var.target_tracking_policy[count.index],
      "scale_out_cooldown",
      0,
    )
    predefined_metric_specification {
      predefined_metric_type = lookup(var.target_tracking_policy[count.index], "predefined_metric_type", "")
    }
  }

  depends_on = [aws_appautoscaling_target.this]
}

resource "aws_appautoscaling_policy" "this_step_scaling" {
  count = var.enable_autoscaling ? length(var.step_policy) : 0

  name               = lookup(var.step_policy[count.index], "name", "")
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.this.name}"
  policy_type        = "StepScaling"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  dynamic "step_scaling_policy_configuration" {
    for_each = var.step_policy
    content {
      adjustment_type          = lookup(step_scaling_policy_configuration.value, "adjustment_type", null)
      cooldown                 = lookup(step_scaling_policy_configuration.value, "cooldown", null)
      metric_aggregation_type  = lookup(step_scaling_policy_configuration.value, "metric_aggregation_type", null)
      min_adjustment_magnitude = lookup(step_scaling_policy_configuration.value, "min_adjustment_magnitude", null)

      dynamic "step_adjustment" {
        for_each = lookup(step_scaling_policy_configuration.value, "step_adjustment", [])
        content {
          metric_interval_lower_bound = lookup(step_adjustment.value, "metric_interval_lower_bound", null)
          metric_interval_upper_bound = lookup(step_adjustment.value, "metric_interval_upper_bound", null)
          scaling_adjustment          = step_adjustment.value.scaling_adjustment
        }
      }
    }
  }

  depends_on = [aws_appautoscaling_target.this]
}

resource "aws_lb_target_group" "this" {
  name                 = "${var.project}-${var.environment}-${var.name}"
  target_type          = "ip"
  vpc_id               = var.vpc_id
  port                 = var.container_port
  protocol             = var.container_protocol
  deregistration_delay = var.deregistration_delay

  health_check {
    interval            = var.healthcheck_lb_interval
    path                = var.health_check_path
    port                = var.container_port
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    protocol            = var.container_protocol
    matcher             = var.health_check_matcher
  }

  stickiness {
    type            = "lb_cookie"
    cookie_duration = var.lb_cookie_duration
    enabled         = var.stickiness_enabled
  }

  tags = {
    Terraform   = "true"
    Environment = var.environment
    Description = "Assigned to ${var.alb_dns_name}"
  }
}

resource "aws_lb_listener_rule" "this_forward" {
  count        = var.listeners_count
  listener_arn = var.listener_arns[count.index]["listener_arn"]
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  condition {
    host_header {
      values = [var.listener_arns[count.index]["target_url"] != "" ? var.listener_arns[count.index]["target_url"] : local.default_target_url]
    }
  }
}

resource "aws_lb_listener_rule" "this_extra" {
  for_each = {
    for index, listener_rule in var.extra_listeners :
    index => listener_rule
    if length(var.extra_listeners) != 0
  }

  listener_arn = var.listener_arns[0]["listener_arn"]
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
  condition {
    host_header {
      values = [each.value.target_url != "" ? each.value.target_url : local.default_target_url]
    }
  }
  condition {
    path_pattern {
      values = [each.value.target_path]
    }
  }
}
