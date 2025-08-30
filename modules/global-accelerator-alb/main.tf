module "alb_sg" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/security-group"

  name   = "${var.project}-${var.environment}-${var.name}-sg"
  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = concat([
    {
      from_port   = var.listener_port
      to_port     = var.listener_port
      protocol    = "tcp"
      cidr_blocks = var.alb_ingress_cidr
      description = "Allow inbound traffic on listener port"
    }
  ], var.additional_alb_ingress_rules)

  egress_with_cidr_blocks = concat([
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = var.alb_egress_cidr
      description = "Allow all outbound traffic"
    }
  ], var.additional_alb_egress_rules)

  tags = merge(var.tags, tomap({ "${var.project}:ModuleName" = "not_supported", "${var.project}:TechnicalFunction" = "network" }))
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.14.0"

  name               = "${var.project}-${var.environment}-${var.name}"
  load_balancer_type = var.load_balancer_type
  internal           = true

  vpc_id          = var.vpc_id
  subnets         = var.public_subnet_ids
  security_groups = [module.alb_sg.security_group_id]

  enable_deletion_protection = var.enable_deletion_protection

  target_groups = {
    main = {
      create_attachment = false
      name              = "${var.project}-${var.environment}-${var.name}"
      target_protocol   = var.target_protocol
      target_port       = var.target_port
      target_type       = var.target_type
      health_check = {
        enabled             = var.health_check_enabled
        interval            = var.health_check_interval
        path                = var.health_check_path
        port                = var.target_port
        healthy_threshold   = var.healthy_threshold
        unhealthy_threshold = var.unhealthy_threshold
        timeout             = var.health_check_timeout
        protocol            = var.target_protocol
        matcher             = var.health_check_matcher
      }
      tags = merge(var.tags, tomap({ "${var.project}:ModuleName" = "not_supported", "${var.project}:TechnicalFunction" = "network" }))
    }
  }

  additional_target_group_attachments = {
    for idx, id in var.instance_ids : "attach_${idx}" => {
      target_group_key = "main"
      target_id        = id
      port             = var.target_port
    }
  }

  listeners = {
    main = {
      port            = var.listener_port
      protocol        = var.listener_protocol
      certificate_arn = var.listener_protocol == "HTTPS" ? var.certificate_arn : null
      forward = {
        target_group_key = "main"
      }
    }
  }

  tags = merge(var.tags, tomap({ "${var.project}:ModuleName" = "not_supported", "${var.project}:TechnicalFunction" = "network" }))
}

module "global_accelerator" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/global-accelerator"

  project                        = var.project
  environment                    = var.environment
  name                           = var.name
  tags                           = var.tags
  ip_address_type                = var.ip_address_type
  accelerator_enabled            = var.accelerator_enabled
  client_affinity                = var.client_affinity
  listener_protocol              = var.ga_listener_protocol
  listener_port                  = var.listener_port
  endpoint_weight                = var.endpoint_weight
  client_ip_preservation_enabled = var.client_ip_preservation_enabled
  endpoint_ids                   = [module.alb.arn]
  health_check_port              = var.listener_port
  health_check_protocol          = var.ga_listener_protocol
  health_check_path              = var.health_check_path
}