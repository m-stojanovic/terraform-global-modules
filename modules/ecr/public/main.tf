data "aws_caller_identity" "current" {}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "2.3.0"

  repository_name                 = var.repository_name
  repository_type                 = var.repository_type
  repository_force_delete         = var.repository_force_delete
  repository_image_scan_on_push   = var.repository_image_scan_on_push
  repository_image_tag_mutability = var.repository_image_tag_mutability

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire untagged images after 1 day",
        selection = {
          tagStatus   = "untagged",
          countType   = "sinceImagePushed",
          countUnit   = "days",
          countNumber = 1
        },
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2,
        description  = "Retain the last ${var.number_of_test_images_to_keep} test images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["test-"],
          countType     = "imageCountMoreThan",
          countNumber   = var.number_of_test_images_to_keep
        },
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 3,
        description  = "Retain the last ${var.number_of_images_to_keep} images",
        selection = {
          tagStatus   = "any",
          countType   = "imageCountMoreThan",
          countNumber = var.number_of_images_to_keep
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  create_repository_policy = var.create_repository_policy
  repository_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "${var.allowed_principals}"
        }
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:InitiateLayerUpload",
          "ecr:DescribeImageScanFindings",
          "ecr:GetAuthorizationToken",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:ListTagsForResource",
          "ecr:ListImages"
        ]
      }
    ]
  })

  create_registry_replication_configuration = var.create_registry_replication_configuration
  registry_replication_rules                = var.registry_replication_rules

  tags = var.tags
}
