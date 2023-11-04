output "this_instance_id" {
  value = module.asg.id
}

output "this_asg_id" {
  value = module.asg.id
}

output "this_target_group_arn" {
  value = "aws_lb_target_group.app_target_group.arn"
}