output "this_instance_id" {
  value = module.instance.id
}

output "this_target_group_arn" {
  value = aws_lb_target_group.this.arn
}