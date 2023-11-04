resource "aws_kms_key" "this" {
  description             = var.description
  policy                  = try(var.policy, null)
  deletion_window_in_days = try(var.deletion_window_in_days, null)
  enable_key_rotation     = try(var.enable_key_rotation, null)
}

resource "aws_kms_alias" "this" {
  name          = var.alias
  target_key_id = aws_kms_key.this.key_id
}