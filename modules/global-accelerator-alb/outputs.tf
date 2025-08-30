output "accelerator_arn" {
  description = "The ARN of the Global Accelerator"
  value       = module.global_accelerator.accelerator_arn
}

output "accelerator_dns_name" {
  description = "The DNS name of the Global Accelerator"
  value       = module.global_accelerator.accelerator_dns_name
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = module.alb.arn
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.alb.dns_name
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = module.alb.target_groups["main"].arn
}

output "security_group_id" {
  description = "The ID of the ALB security group"
  value       = module.alb_sg.security_group_id
}