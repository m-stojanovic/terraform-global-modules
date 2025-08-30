output "route53_zone_zone_id" {
  description = "Zone ID of Route53 zone"
  value       = module.route53.route53_zone_zone_id
}

output "route53_zone_zone_arn" {
  description = "Zone ARN of Route53 zone"
  value       = module.route53.route53_zone_zone_arn
}

output "route53_zone_name_servers" {
  description = "Name servers of Route53 zone"
  value       = module.route53.route53_zone_name_servers
}

output "primary_name_server" {
  description = "The Route 53 name server that created the SOA record."
  value       = module.route53.primary_name_server
}

output "route53_zone_name" {
  description = "Name of Route53 zone"
  value       = module.route53.route53_zone_name
}

output "route53_static_zone_name" {
  description = "Name of Route53 zone created statically to avoid invalid count argument error when creating records and zones simmultaneously"
  value       = module.route53.route53_static_zone_name
}
