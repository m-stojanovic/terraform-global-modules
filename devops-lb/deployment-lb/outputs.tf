
output "security_group_id" {
  value = (length(aws_security_group.this) > 0) ? aws_security_group.this[0].id : null
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "alb_arn" {
  value = aws_lb.this.arn
}

output "alb_id" {
  value = aws_lb.this.id
}

output "listener_443_arn" {
  value = aws_lb_listener.port_443.arn
}

output "listener_80_arn" {
  value = aws_lb_listener.port_80.arn
}

output "listener_9200_arn" {
  value = aws_lb_listener.port_9200.arn
}

output "listener_9000_arn" {
  value = aws_lb_listener.port_9000.arn
}

output "listener_8080_arn" {
  value = aws_lb_listener.port_8080.arn
}

output "arn_suffix" {
  value = aws_lb.this.arn_suffix
}
