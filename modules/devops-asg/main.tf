data "template_file" "cloud-init-app" {
  template = file("${path.module}/user-data/cloud-config.yaml")

  vars = {
    HOSTNAME    = var.name
    ENVIRONMENT = local.environment_without_suffix
  }
}

resource "aws_autoscaling_group" "app_asg" {
  name                      = "${var.name}-asg"
  max_size                  = var.asg_max
  min_size                  = var.asg_min
  desired_capacity          = var.desired_capacity
  force_delete              = true
  placement_group           = var.placement_group
  health_check_type         = "EC2"
  health_check_grace_period = 120
  default_cooldown          = 60
  termination_policies      = ["OldestInstance", "Default"]
  vpc_zone_identifier       = var.subnet_id

  mixed_instances_policy {
    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.app_lt.id
        version            = "$Latest"
      }

      dynamic "override" {
        for_each = var.instance_types
        content {
          instance_type = override.value
        }
      }
    }
    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_base_capacity
      on_demand_percentage_above_base_capacity = local.on_demand_percentage_above_base_capacity
      spot_allocation_strategy                 = var.spot_allocation_strategy
      spot_instance_pools                      = var.spot_instance_pools
      spot_max_price                           = var.spot_max_price
    }
  }

  lifecycle {
    ignore_changes = [target_group_arns]
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }
  tag {
    key                 = "env"
    value               = "${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.name}-lt-"
  image_id      = var.ami
  instance_type = var.instance_types[0]
  user_data     = var.aws_user_data == "" ? base64encode(data.template_file.cloud-init-app.rendered) : base64encode(var.aws_user_data)
  ebs_optimized = var.ebs_optimized
  key_name      = var.key_name

  iam_instance_profile {
    name = var.aws_iam_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = var.vpc_security_group_ids
    delete_on_termination       = true
  }

  lifecycle {
    create_before_destroy = true
  }

  block_device_mappings {
    no_device   = "true"
    device_name = "/dev/xvda"
    ebs {
      volume_type           = var.ebs_root_volume_type
      volume_size           = var.ebs_root_volume_size
      delete_on_termination = "true"
      encrypted             = "true"
    }
  }

  credit_specification {
    cpu_credits = var.credit_specification
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(tomap({ "Name" = "${var.name}" }), var.tags)
  }
}
