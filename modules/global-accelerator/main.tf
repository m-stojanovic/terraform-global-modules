resource "aws_globalaccelerator_accelerator" "this" {
  name            = "${var.project}-${var.environment}-${var.name}"
  ip_address_type = var.ip_address_type
  enabled         = var.accelerator_enabled

  tags = merge(var.tags, tomap({ "${var.project}:ModuleName" = "global-accelerator", "${var.project}:TechnicalFunction" = "network" }))
}

resource "aws_globalaccelerator_listener" "this" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.arn
  client_affinity = var.client_affinity
  protocol        = var.listener_protocol

  port_range {
    from_port = var.listener_port
    to_port   = var.listener_port
  }
}

resource "aws_globalaccelerator_endpoint_group" "this" {
  listener_arn          = aws_globalaccelerator_listener.this.arn
  health_check_port     = var.health_check_port
  health_check_protocol = var.health_check_protocol
  health_check_path     = var.health_check_path

  dynamic "endpoint_configuration" {
    for_each = var.endpoint_ids

    content {
      endpoint_id                    = endpoint_configuration.value
      weight                         = var.endpoint_weight
      client_ip_preservation_enabled = var.client_ip_preservation_enabled
    }
  }
}