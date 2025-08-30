variable "project" {
  type        = string
  description = "The name of the project" 
}

variable "container_name" {
  type        = string
  description = "The name of the container"
}

variable "image_name" {
  type        = string
  description = "The name of the image in ECR"
}

variable "image_tag" {
  type        = string
  description = "The tag of the image in ECR"
}

variable "container_cpu" {
  type        = number
  description = "The number of cpu units reserved for the container"
}

variable "container_memory" {
  type        = number
  default     = 0
  description = "The hard limit (in MiB) of memory to present to the container"
}

variable "container_memory_reservation" {
  type        = number
  default     = 0
  description = "The soft limit (in MiB) of memory to reserve for the container"
}

variable "container_entry_points" {
  type        = list(string)
  default     = []
  description = "The entry point that is passed to the container"
}

variable "container_commands" {
  type        = list(string)
  default     = []
  description = "The command that is passed to the container"
}

variable "environment_variables" {
  type = list(object({
    name  = string
    value = string
  }))
  default     = []
  description = "A list of environment variables to pass to the container"
}

variable "mount_points" {
  type = list(object({
    sourceVolume  = string
    containerPath = string
    readOnly      = bool
  }))
  default     = []
  description = "A list of mount points to pass to the container"
}

variable "volumes_from" {
  type        = list(string)
  default     = []
  description = "A list of data volumes to mount from another container"
}

variable "secrets" {
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default     = []
  description = "A list of secret parameters to pass from SSM to the container"
}

variable "ecs_depends_on" {
  type        = list(string)
  default     = []
  description = "A list of dependencies to pass to the container"
}

variable "dns_servers" {
  type        = list(string)
  default     = []
  description = "A list of dns servers to use in the container"
}

variable "dns_search_domains" {
  type        = list(string)
  default     = []
  description = "A list of dns search domains to use in the container"
}

variable "extra_hosts" {
  type        = list(string)
  default     = []
  description = "A list of extra hosts to resolve in the container"
}

variable "interactive" {
  type        = string
  default     = false
  description = "Whether to deploy containerized applications that require stdin or tty"
}

variable "ulimits" {
  type        = list(string)
  default     = []
  description = "A list of ulimits for the container"
}

variable "health_check_default_enabled" {
  description = "Enable or disable health checks"
  type        = bool
  default     = true
}

variable "healthcheck_retries" {
  type        = number
  default     = 3
  description = "The number of times to retry a failed health check before the container is considered unhealthy"
}

variable "healthcheck_timeout" {
  type        = number
  default     = 5
  description = "The time period in seconds to wait for a health check to succeed before it is considered a failure"
}

variable "healthcheck_interval" {
  type        = number
  default     = 30
  description = "The time period in seconds between each health check execution"
}

variable "healthcheck_start_period" {
  type        = number
  default     = 90
  description = "The optional grace period within which to provide containers time to bootstrap before failed health checks count towards the maximum number of retries"
}

variable "container_protocol" {
  type        = string
  default     = "tcp"
  description = "The protocol used for the port mapping"
}

variable "container_port" {
  type        = number
  description = "The port number on the container that is bound to the user-specified or automatically assigned host port"
}

variable "environment" {
  type        = string
  description = "The name of the environment"
}

variable "environment_number" {
  type        = string
  description = "The number of the environment"
}

variable "task_cpu" {
  type        = number
  description = "The number of cpu units used by the task"
}

variable "task_memory" {
  type        = number
  description = "The amount (in MiB) of memory used by the task"
}

variable "task_execution_role_arn" {
  type        = string
  description = "The ARN of the IAM task execution role for the task"
}

variable "name" {
  type        = string
  description = "The name of the service"
}

variable "cluster_arn" {
  type        = string
  description = "the ARN of the ECS cluster"
}

variable "desired_count" {
  type        = string
  default     = "0"
  description = "The number of instances of the task definition to place and keep running"
}

variable "ecs_platform_version" {
  type        = string
  default     = "1.4.0"
  description = "The platform version on which to run the service"
}

variable "deployment_maximum_percent" {
  type        = string
  default     = "200"
  description = "The upper limit (as a percentage of the service's desiredCount) of the number of running tasks that can be running in a service during a deployment"
}

variable "deployment_minimum_healthy_percent" {
  type        = string
  default     = "100"
  description = "The lower limit (as a percentage of the service's desiredCount) of the number of running tasks that must remain running and healthy in a service during a deployment"
}

variable "deployment_controller_type" {
  type        = string
  default     = "ECS"
  description = "Definition of the deployment controller type. Valid values: CODE_DEPLOY, ECS, EXTERNAL. Default: ECS."
}

variable "health_check_grace_period_seconds" {
  type        = string
  default     = ""
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown"
}

variable "security_groups" {
  type        = list(string)
  description = "The security groups associated with the service"
}

variable "private_subnets" {
  type        = list(string)
  description = "The subnets associated with the service"
}

variable "enable_autoscaling" {
  type        = string
  default     = "false"
  description = "Whether to enable autoscaling for the ECS service"
}

variable "max_capacity" {
  type        = string
  description = "The max capacity of the scalable target"
}

variable "min_capacity" {
  type        = string
  description = "The min capacity of the scalable target"
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "ecs_autoscaling_role_arn" {
  type        = string
  description = "The ARN of the IAM role to modify the scalable target"
}

variable "target_tracking_policy" {
  type = list(object({
    name                   = string
    target_value           = number
    scale_in_cooldown      = number
    scale_out_cooldown     = number
    predefined_metric_type = string
  }))
  default     = []
  description = "An array of target tracking autoscaling policies"
}

variable "step_policy" {
  type = list(object({
    adjustment_type          = string
    cooldown                 = number
    metric_aggregation_type  = string
    min_adjustment_magnitude = number
    step_adjustment = object({
      metric_interval_lower_bound = number
      metric_interval_upper_bound = number
      scaling_adjustment          = number
    })
  }))
  default     = []
  description = "An array of step autoscaling policies"
}

variable "vpc_id" {
  type    = string
  default = ""
}

variable "health_check_path" {
  default = ""
}

variable "health_check_healthy_threshold" {
  default = "2"
}

variable "health_check_unhealthy_threshold" {
  default = "2"
}

variable "health_check_timeout" {
  default = "5"
}

variable "health_check_matcher" {
  default = ""
}

variable "healthcheck_lb_interval" {
  default = "90"
}

variable "listener_arns" {
  type = list(object({
    listener_arn = string
    target_url   = string
  }))
  default = []
}

variable "deregistration_delay" {
  default = "30"
}

variable "listeners_count" {
  type    = string
  default = "1"
}

variable "splunk_host" {
  type    = string
  default = "http-inputs.devops.splunkcloud.com"
}

variable "splunk_token" {
  type    = string
  default = ""
}

variable "splunk_index" {
  type    = string
  default = "dev-apps"
}

variable "healthcheck_custom_commands" {
  default = null
}

locals {
  default_target_url = "${var.name}${var.environment_number}.*"
  log_options_aws = {
    awslogs-group         = "/ecs/${var.name}-task-def-${var.environment}"
    awslogs-region        = "eu-west-1"
    awslogs-stream-prefix = "${var.environment}/${var.container_name}/${var.name}_task_def"
  }
  log_options_splunk = {
    Name             = "splunk"
    host             = var.splunk_host
    port             = "443"
    splunk_token     = var.splunk_token
    event_key        = "$log"
    event_index      = var.splunk_index
    tls              = "On"
    event_sourcetype = var.name
    event_source     = var.cluster_name
    event_host       = "$container_id"
  }
  log_options = var.cloudwatch_logs_enabled ? local.log_options_aws : local.log_options_splunk
  healthcheck_commands = var.health_check_default_enabled ? [
    "CMD-SHELL",
    "curl -f localhost:${var.container_port}${var.health_check_path} || exit 1",
  ] : []
  healthcheck_fluentbit_commands = [
    "CMD-SHELL",
    "test -f /extra.conf || exit $?",
  ]
}

variable "alb_dns_name" {
  type = string
}

variable "alb_arn_suffix" {
  type = string
}

variable "cloudwatch_logs_enabled" {
  default = "false"
}

variable "lb_cookie_duration" {
  type    = string
  default = "86400"
}

variable "stickiness_enabled" {
  default = false
}

variable "create_alarm" {
  default = "0"
}

variable "evaluation_periods" {
  default = "1"
}

variable "healthy_host_threshold" {
  description = "Unhealthy treshold for cloudwatch metrics"
  default     = "0"
}

variable "healthy_host_datapoints_to_alarm" {
  default = "1"
}

variable "err_5xx_count_threshold" {
  description = "Threshold for max number of 5xx errors"
  default     = "50"
}

variable "err_5xx_count_datapoints_to_alarm" {
  default = "1"
}

variable "target_connection_error_count_threshold" {
  description = "Threshold for max number of target group connection errors"
  default     = "5"
}

variable "target_connection_error_count_datapoints_to_alarm" {
  default = "1"
}

variable "capacity_provider" {
  default = "FARGATE"
}

variable "fluentbit_image" {
  type    = string
  default = "123456789.dkr.ecr.eu-west-1.amazonaws.com/devops/fluent-bit:latest"
}

variable "extra_listeners" {
  type = list(object({
    target_url  = string
    target_path = string
  }))
  default = []
}

variable "efs_volume_id" {
  type        = string
  description = "The id of the EFS volume"
  default     = null
}
