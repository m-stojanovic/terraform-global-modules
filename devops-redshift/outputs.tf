output "this_security_group_id" {
  description = "List of associated security groups of instances, if running in non-default VPC"
  value       = [aws_security_group.this.id]
}