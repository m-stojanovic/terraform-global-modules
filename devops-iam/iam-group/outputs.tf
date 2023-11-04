output "this_group_name" {
  description = "The name of the IAM group"
  value       = aws_iam_group.this.name
}