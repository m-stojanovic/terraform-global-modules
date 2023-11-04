
resource "aws_security_group" "this" {
  count       = var.create_aws_security_group ? 1 : 0
  name        = "${var.environment}-${var.alb_name}-lb-sg"
  description = "Security group to allow access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "allow access on port 443"
    cidr_blocks = var.full_access_cidrs
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "allow access on port 80"
    cidr_blocks = var.full_access_cidrs
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    description = "allow external access to everywhere"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({ "Name" = "${var.environment}-${var.alb_name}-lb-sg" }), var.tags)

}

resource "aws_lb" "this" {
  name                       = "${var.environment}-${var.alb_name}-lb"
  internal                   = var.is_internal
  load_balancer_type         = "application"
  security_groups            = length(aws_security_group.this) > 0 ? concat([aws_security_group.this[0].id], var.additional_sgs) : var.additional_sgs
  subnets                    = var.subnets_id
  idle_timeout               = "360"
  enable_deletion_protection = false

  access_logs {
    bucket  = var.access_logs_bucket
    prefix  = var.access_logs_prefix
    enabled = var.access_logs_enable
  }

  tags = merge(tomap({ "Name" = "${var.environment}-${var.alb_name}-lb" }), var.tags)

}

resource "aws_lb_target_group" "this" {
  name     = "${var.environment}-${var.alb_name}-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

# LISTENERS $ CERTIFICATES

resource "aws_lb_listener_certificate" "devdevops_port_443" {
  listener_arn    = aws_lb_listener.port_443.arn
  certificate_arn = var.devdevops_cert
}

resource "aws_lb_listener" "port_443" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = var.listener_ssl_policy
  certificate_arn   = var.devdevops_cert
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}