variable "role_name" {}

variable "policy_name" {}

variable "profile_name" {}

variable "s3_bucket_limited_access_policy_name" {}

variable "policy_sid" {}

variable "static_url" {}

variable "videos_s3_bucket_url" {}

variable "mkt_bucket" {}

variable "av_bucket" {}

variable "private_bucket" {}

variable "environment" {}

variable "sns_publish_policy_name" {}

variable "environment_name" {}

variable "sqs_send_receive_delete_policy_name" {}

variable "iam_group_name" {}

variable "group_membership_name" {}

variable "iam_vpc_user" {}

variable "redshift_data_bucket" {}

variable "devops_resources_account_id" {
  default = "123456789"
}

variable "devops_main_account_id" {
  default = "123456789876"
}

variable "data_files_s3_bucket_url" {
  default = "devops-data-files"
}

variable "citrusad_bucket" {
  default = "citrusad.devdevops.co.uk"
}
