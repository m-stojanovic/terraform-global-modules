/*
  IAM Policy for Code Pipeline resources
  All Code Pipeline projects in an environment will use the same IAM policy
*/
resource "aws_iam_policy" "code_pipeline_policy" {
  count       = var.create_pipeline ? 1 : 0
  name        = "CodePipeline${var.environment_name_iam}ServiceRolePolicy"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodePipeline for ${var.environment_name_iam}"
  policy      = file("${path.module}/policies/code-pipeline-policy.json")
}

/*
  Data for assume role policy template regarding code pipeline projects
  Service = codepipeline.amazonaws.com
*/
data "template_file" "pipeline_assume_role_policy" {
  template = file("${path.module}/policies/assume-role-policy.json.tpl")
  vars = {
    service = "codepipeline.amazonaws.com"
  }
}

/*
  IAM Role for Code Pipeline resources
  All Code Pipeline projects in an environment will use the same IAM role
*/
resource "aws_iam_role" "code_pipeline_role" {
  count              = var.create_pipeline ? 1 : 0
  name               = "CodePipeline${var.environment_name_iam}ServiceRole"
  path               = "/service-role/"
  description        = "Role used in trust relationship with CodePipeline for ${var.environment_name_iam}"
  assume_role_policy = data.template_file.pipeline_assume_role_policy.rendered
}

/*
  IAM policy attachment for code pipeline
*/
resource "aws_iam_role_policy_attachment" "code_pipeline_role_policy_attachment" {
  count      = var.create_pipeline ? 1 : 0
  role       = aws_iam_role.code_pipeline_role[0].name
  policy_arn = aws_iam_policy.code_pipeline_policy[0].arn
}

/*
  IAM Policy for Code Build resources
  All Code Build projects in an environment will use the same IAM policy
*/
resource "aws_iam_policy" "code_build_policy" {
  count       = var.create_pipeline ? 1 : 0
  name        = "${var.environment_name_iam}CodeBuildBasePolicy"
  path        = "/service-role/"
  description = "Policy used in trust relationship with CodeBuild for ${var.environment_name_iam}"
  policy      = file("${path.module}/policies/code-build-policy.json")
}

/*
  Data for assume role policy template regarding code build projects
  Service = codebuild.amazonaws.com
*/
data "template_file" "build_assume_role_policy" {
  template = file("${path.module}/policies/assume-role-policy.json.tpl")

  vars = {
    service = "codebuild.amazonaws.com"
  }
}

/*
  IAM Role for Code Build resources
  All Code Build projects in an environment will use the same IAM role
*/
resource "aws_iam_role" "code_build_role" {
  count              = var.create_pipeline ? 1 : 0
  name               = "${var.environment_name_iam}CodeBuildRole"
  path               = "/service-role/"
  description        = "Role used in trust relationship with CodeBuild for ${var.environment_name_iam}"
  assume_role_policy = data.template_file.build_assume_role_policy.rendered
}

/*
  IAM policy attachment for code build
*/
resource "aws_iam_role_policy_attachment" "code_build_role_policy_attachment" {
  count      = var.create_pipeline ? 1 : 0
  role       = aws_iam_role.code_build_role[0].name
  policy_arn = aws_iam_policy.code_build_policy[0].arn
}

data "template_file" "ecs_scheduled_event_assume_role_policy" {
  template = file("${path.module}/policies/assume-role-policy.json.tpl")

  vars = {
    service = "events.amazonaws.com"
  }
}

resource "aws_iam_role" "ecs_scheduled_event_role" {
  name               = "${var.environment_name_iam}ecsScheduledEventRole"
  path               = "/"
  description        = "Role used for ecs scheduled events"
  assume_role_policy = data.template_file.ecs_scheduled_event_assume_role_policy.rendered
}

resource "aws_iam_role_policy" "ecs_scheduled_event_policy" {
  name   = "${var.environment_name_iam}EcsScheduledEventPolicy"
  role   = aws_iam_role.ecs_scheduled_event_role.id
  policy = file("${path.module}/policies/ecs-run-task-policy.json")
}

resource "aws_iam_user" "env_user" {
  name = var.username
}

resource "aws_iam_access_key" "env_key" {
  user = aws_iam_user.env_user.name
}
