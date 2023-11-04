variable "create_policy" {
  description = "Create SNS Policy"
  type        = bool
}

variable "sns_topic_name" {
  description = "SNS topic name"
  type        = string
}

variable "fifo_topic" {
  description = "Enable FIFO topic"
  type        = bool
}

variable "content_based_deduplication" {
  description = "Enable content based deduplication"
  type        = bool
}

variable "sns_topic_policy" {
  description = "SNS Policy"
  type        = any
}