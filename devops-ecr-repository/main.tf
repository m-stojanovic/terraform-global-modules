resource "aws_ecr_repository" "ecr_repository" {
  name = var.repository_name
  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }
}

data "template_file" "ecr_repo_lifecycle_policy_json" {
  template = file("${path.module}/policies/lifecycle_policy.json.tpl")
  vars = {
    count_number = var.number_of_images_to_keep
    count_days   = var.days_of_untagged_images_to_keep
  }
}

resource "aws_ecr_lifecycle_policy" "repository_lifecycle_policy" {
  repository = aws_ecr_repository.ecr_repository.name

  policy = data.template_file.ecr_repo_lifecycle_policy_json.rendered
}

data "template_file" "ecr_repository_policy_json" {
  template = file("${path.module}/policies/repository_policy.json.tpl")
  vars = {
    policy_sid      = "${aws_ecr_repository.ecr_repository.name}_sid"
    repository_name = var.repository_name
    ecr_principal   = jsonencode(split(",", trimspace(var.principal)))
  }
}

resource "aws_ecr_repository_policy" "repository_policy" {
  repository = aws_ecr_repository.ecr_repository.name

  policy = data.template_file.ecr_repository_policy_json.rendered
}

