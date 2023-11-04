resource "aws_iam_role" "this" {
  #count              = var.create_iam_role ? 1 : 0
  path               = var.path
  name               = var.name
  description        = var.description
  assume_role_policy = var.assume_role_policy
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = var.create_policy_attachment ? 1 : 0
  role       = aws_iam_role.this.name
  policy_arn = var.policy_arn
  depends_on = [
    aws_iam_role.this
  ]
}

resource "aws_iam_role_policy" "this" {
  count  = var.create_iam_role_policy ? 1 : 0
  name   = var.iam_role_policy_name
  role   = aws_iam_role.this.id
  policy = var.iam_role_policy
}