output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable."
  value       = module.ec2.public_ip
}

output "id" {
  description = "The ID of the EC2 instance"
  value       = module.ec2.id
}

output "arn" {
  description = "The ARN of the EC2 instance"
  value       = module.ec2.arn
}

output "private_ip" {
  description = "The private IP address assigned to the instance"
  value       = module.ec2.private_ip
}
