output "cluster_id" {
  description = "The ID of the DocumentDB Elastic Cluster"
  value       = aws_docdbelastic_cluster.this.id
}

output "cluster_endpoint" {
  description = "The endpoint of the DocumentDB Elastic Cluster"
  value       = aws_docdbelastic_cluster.this.endpoint
}

output "cluster_arn" {
  description = "The ARN of the DocumentDB Elastic Cluster"
  value       = aws_docdbelastic_cluster.this.arn
}

output "secret_arn" {
  description = "The ARN of the Secrets Manager secret storing DocumentDB credentials"
  value       = aws_secretsmanager_secret.this.arn
}

output "security_group_id" {
  description = "The ID of the security group for DocumentDB"
  value       = module.security-group.security_group_id
}
