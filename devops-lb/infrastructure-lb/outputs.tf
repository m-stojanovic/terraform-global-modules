output "lb_name" {
  description = "Name of the LB"
  value       = aws_lb.loadbalancer.name
}

output "lb_arn" {
  description = "ARN of the LB"
  value       = aws_lb.loadbalancer.arn
}

output "lb_dns_name" {
  description = "DNS name of the LB"
  value       = aws_lb.loadbalancer.dns_name
}

output "lb_zone_id" {
  description = "ID of the zone which LB is provisioned in"
  value       = aws_lb.loadbalancer.zone_id
}

output "access_logs_bucket_id" {
  description = "S3 bucket ID for access logs"
  value       = try(module.s3_bucket[0].s3_bucket_id, null)
}