data "local_file" "pgp_key" {
  filename = "${path.module}/files/pgp_key.gpg"
}

resource "aws_iam_user" "this" {
  name          = var.user_name
  path          = var.path
  force_destroy = var.force_destroy

  tags = {
    title        = var.title
    access_level = var.access_level
    email        = var.email
    name         = var.name
  }
}

resource "aws_iam_access_key" "this" {
  count   = var.create_access_keys ? 1 : 0
  user    = aws_iam_user.this.name
  pgp_key = var.pgp_key != null ? var.pgp_key : data.local_file.pgp_key.content_base64

}

resource "aws_iam_user_login_profile" "this" {
  count                   = var.create_password ? 1 : 0
  user                    = aws_iam_user.this.name
  pgp_key                 = var.pgp_key != null ? var.pgp_key : data.local_file.pgp_key.content_base64
  password_length         = var.password_length
  password_reset_required = var.password_reset_required
}

resource "aws_iam_user_ssh_key" "this" {
  count      = var.upload_ssh_key ? 1 : 0
  username   = aws_iam_user.this.name
  encoding   = var.encoding
  public_key = var.public_key
}

resource "aws_iam_user_group_membership" "this" {
  user   = aws_iam_user.this.name
  groups = var.groups
}