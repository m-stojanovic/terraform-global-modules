output "this_zone_id" {
  value       = aws_route53_zone.this.zone_id
  description = "The ID of the private DNS zone"
}

