locals {
  target_group_attachments_list = flatten([
    for item in var.target_group_attachments : [
      length(item.target_ids) > 0 ? # check if target_ids is present
      [for tid in item.target_ids : {
        "${tid}_${item.target_group_index}" = {
          "target_group_index" = item.target_group_index
          "target_id"          = "${tid}"
          "port"               = try(item.port, null)
          "availability_zone"  = try(item.availability_zone, null)
        }
      }]
      : # if target_ids is not present, create a single map
      [
        {
          "${item.target_group_index}" = {
            "target_group_index" = item.target_group_index
            "port"               = try(item.port, null)
            "availability_zone"  = try(item.availability_zone, null)
          }
        }
      ]
    ]
  ])

  target_group_attachments = { for item in local.target_group_attachments_list :
    keys(item)[0] => values(item)[0]
  }

  listener_cert_list = flatten([
    for item in var.listeners : try(item.certificate_arn, null)
  ])

  listener_protocol_list = flatten([
    for item in var.listeners : try(item.protocol, null)
  ])

  listener_tls_flag = contains(local.listener_protocol_list, "TLS")

  #enable_logging = var.load_balancer_type == "application" || (var.load_balancer_type == "network" && local.listener_tls_flag) ? true : null
}

data "aws_acm_certificate" "certificates" {
  for_each = toset(compact(local.listener_cert_list))

  domain      = join(".", ["*", replace(each.value, "_", ".")])
  statuses    = ["ISSUED"]
  most_recent = true
}

module "s3_bucket" {
  source = "git@bitbucket.org:devopsdevops/global-modules.git//devops-s3-public"

  count = var.enable_logging == true ? 1 : 0

  bucket = "${var.tags["devops:env"]}-${var.aws_region}-${var.load_balancer_type}-lb-logs-${var.name}"

  block_public_acls             = true
  block_public_policy           = true
  ignore_public_acls            = true
  restrict_public_buckets       = true
  attach_lb_log_delivery_policy = true
  force_destroy                 = true
  acl                           = "private"
  tags                          = var.tags

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_lb" "loadbalancer" {
  name                             = var.name
  internal                         = try(var.internal, null)
  load_balancer_type               = try(var.load_balancer_type, null)
  security_groups                  = try(var.security_groups, null)
  drop_invalid_header_fields       = try(var.drop_invalid_header_fields, null)
  subnets                          = var.subnet_mappings != null ? null : var.subnets
  idle_timeout                     = try(var.idle_timeout, null)
  enable_deletion_protection       = try(var.enable_deletion_protection, null)
  enable_cross_zone_load_balancing = try(var.enable_cross_zone_load_balancing, null)
  enable_http2                     = try(var.enable_http2, null)
  enable_waf_fail_open             = try(var.enable_waf_fail_open, null)
  customer_owned_ipv4_pool         = try(var.customer_owned_ipv4_pool, null)
  ip_address_type                  = try(var.ip_address_type, null)
  desync_mitigation_mode           = try(var.desync_mitigation_mode, null)
  tags                             = try(var.tags, null)

  dynamic "access_logs" {
    for_each = var.enable_logging[*]

    content {
      enabled = true
      bucket  = module.s3_bucket[0].s3_bucket_id
    }
  }

  dynamic "subnet_mapping" {
    for_each = var.subnet_mappings[*]

    content {
      subnet_id            = subnet_mapping.value.subnet_id
      allocation_id        = try(subnet_mapping.value.allocation_id, null)
      private_ipv4_address = try(subnet_mapping.value.private_ipv4_address, null)
      ipv6_address         = try(subnet_mapping.value.ipv6_address, null)
    }
  }
}

resource "aws_lb_listener" "lb_listener" {
  for_each = var.listeners

  load_balancer_arn = aws_lb.loadbalancer.arn
  alpn_policy       = try(each.value.alpn_policy, null)
  certificate_arn   = (each.value.certificate_arn != null && each.value.certificate_arn != "") ? data.aws_acm_certificate.certificates["${each.value.certificate_arn}"].arn : null
  port              = try(each.value.port, null)
  protocol          = try(each.value.protocol, null)
  ssl_policy        = try(each.value.ssl_policy, null)
  tags              = try(var.tags, null)

  dynamic "default_action" {
    for_each = each.value.default_action

    content {
      type             = default_action.value.type
      order            = try(default_action.value.order, null)
      target_group_arn = try(aws_lb_target_group.lb_target_group[default_action.value.target_group_index].arn, null)

      dynamic "fixed_response" {
        for_each = default_action.value.fixed_response[*]

        content {
          content_type = fixed_response.value.content_type
          message_body = try(fixed_response.value.message_body, null)
          status_code  = try(fixed_response.value.status_code, null)
        }
      }

      dynamic "forward" {
        for_each = default_action.value.forward[*]

        content {
          dynamic "target_group" {
            for_each = forward.value.target_group

            content {
              arn    = aws_lb_target_group.lb_target_group[target_group.value.target_group_index].arn
              weight = try(target_group.value.weight, null)
            }
          }
          dynamic "stickiness" {
            for_each = forward.value.stickiness[*]

            content {
              duration = stickiness.value.duration
              enabled  = try(stickiness.value.enabled, null)
            }
          }
        }
      }

      dynamic "redirect" {
        for_each = default_action.value.redirect[*]

        content {
          status_code = redirect.value.status_code
          host        = try(redirect.value.host, null)
          path        = try(redirect.value.path, null)
          port        = try(redirect.value.port, null)
          protocol    = try(redirect.value.protocol, null)
          query       = try(redirect.value.query, null)
        }
      }
    }
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  for_each = var.target_groups

  connection_termination             = try(each.value.connection_termination, null)
  deregistration_delay               = try(each.value.deregistration_delay, null)
  lambda_multi_value_headers_enabled = try(each.value.lambda_multi_value_headers_enabled, null)
  load_balancing_algorithm_type      = try(each.value.load_balancing_algorithm_type, null)
  name_prefix                        = try(each.value.name_prefix, null)
  name                               = try(each.value.name, null)
  port                               = try(each.value.port, null)
  preserve_client_ip                 = try(each.value.preserve_client_ip, null)
  protocol_version                   = try(each.value.protocol_version, null)
  protocol                           = try(each.value.protocol, null)
  proxy_protocol_v2                  = try(each.value.proxy_protocol_v2, null)
  slow_start                         = try(each.value.slow_start, null)
  tags                               = try(var.tags, null)
  target_type                        = try(each.value.target_type, null)
  vpc_id                             = try(var.vpc_id, null)

  dynamic "health_check" {
    for_each = each.value.health_check[*]

    content {
      enabled             = try(health_check.value.enabled, null)
      matcher             = try(health_check.value.matcher, null)
      path                = try(health_check.value.path, null)
      timeout             = try(health_check.value.timeout, null)
      protocol            = try(health_check.value.protocol, null)
      port                = try(health_check.value.port, null)
      interval            = try(health_check.value.interval, null)
      healthy_threshold   = try(health_check.value.healthy_threshold, null)
      unhealthy_threshold = try(health_check.value.unhealthy_threshold, null)
    }
  }

  dynamic "stickiness" {
    for_each = each.value.stickiness[*]

    content {
      cookie_duration = try(stickiness.value.cookie_duration, null)
      cookie_name     = try(stickiness.value.cookie_name, null)
      enabled         = try(stickiness.value.enabled, null)
      type            = try(stickiness.value.type, null)
    }
  }
}

resource "aws_lb_target_group_attachment" "lb_target_group_attachment" {
  for_each = local.target_group_attachments

  target_group_arn  = aws_lb_target_group.lb_target_group[each.value.target_group_index].arn
  target_id         = contains(keys(each.value), "target_id") ? tostring(each.value.target_id) : try(var.instance_ids[0], null)
  port              = try(each.value.port, null)
  availability_zone = try(each.value.availability_zone, null)
}