output "name" {
  value = aws_iam_user.env_user.name
}

output "key" {
  value = aws_iam_access_key.env_key.id
}

output "this_ecsScheduled_event_role_arn" {
  value = aws_iam_role.ecs_scheduled_event_role.arn
}

