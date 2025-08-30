output "accelerator_arn" {
  description = "The ARN of the Global Accelerator"
  value       = aws_globalaccelerator_accelerator.this.arn
}

output "accelerator_dns_name" {
  description = "The DNS name of the Global Accelerator"
  value       = aws_globalaccelerator_accelerator.this.dns_name
}