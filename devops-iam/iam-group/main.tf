resource "aws_iam_group" "this" {
  name = var.group_name
  path = var.path
}

resource "aws_iam_group_policy_attachment" "this" {
  count      = var.attach_policies == "true" ? var.computed_number_of_policies : 0
  group      = aws_iam_group.this.name
  policy_arn = element(var.group_policies, count.index)
}