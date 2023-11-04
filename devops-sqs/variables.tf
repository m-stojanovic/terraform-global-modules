variable "create_policy" {
  description = "Create SQS Policy"
  type        = bool
  default     = false
}

variable "sqs_queue_name" {
  description = "SQS topic name"
  type        = string
}

variable "sqs_queue_policy" {
  description = "SQS Policy"
  type        = any
}

variable "delay_seconds" {
  type = number
  default = null
}
variable "message_retention_seconds" {
  type = number
  default = null
}
variable "max_message_size" {
  type = number
  default = null
}