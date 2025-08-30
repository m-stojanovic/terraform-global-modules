resource "random_password" "this" {
  length  = 20
  special = false
}

resource "aws_secretsmanager_secret" "this" {
  name                    = "data_storage/documentdb.${var.name}.credentials"
  description             = "DocumentDB Elastic Cluster username and password."
  recovery_window_in_days = 7

  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "secret_management" }))
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    username = var.admin_user_username
    password = random_password.this.result
  })
}

data "aws_secretsmanager_secret_version" "this" {
  secret_id  = aws_secretsmanager_secret.this.id
  depends_on = [aws_secretsmanager_secret_version.this]
}

resource "aws_docdbelastic_cluster" "this" {
  name                         = "${var.project}-${var.environment}-documentdb-${var.name}-cluster"
  admin_user_name              = var.admin_user_username
  admin_user_password          = jsondecode(data.aws_secretsmanager_secret_version.this.secret_string)["password"]
  auth_type                    = var.auth_type
  shard_capacity               = var.shard_capacity
  shard_count                  = var.shard_count
  preferred_maintenance_window = var.preferred_maintenance_window
  subnet_ids                   = var.subnet_ids
  vpc_security_group_ids       = [module.security-group.security_group_id]
  tags                         = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "data_storage" }))

  lifecycle {
    ignore_changes = [admin_user_password] # due to https://github.com/hashicorp/terraform-provider-aws/issues/39534 we manually need to update new password through AWS console. 
  }                                        # once the bug is resolved we can remove lifecycle and update the documentdb admin password through terraform
}

module "security-group" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/security-group"

  name        = "${var.project}-${var.environment}-documentdb-${var.name}-sg"
  description = "Allow inbound traffic to DocumentDB Elastic Cluster"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = concat([
    {
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      description = "Allow inbound traffic from VPC"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      description = "Allow inbound traffic from VPN"
      cidr_blocks = var.vpn_cidr
    }
  ], var.additional_ingress_rules)

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-documentdb-${var.name}-sg" }), tomap({ "${var.project}:TechnicalFunction" = "network" }))
}

resource "aws_secretsmanager_secret" "endpoint" {
  name                    = "data_storage/documentdb.${var.name}.endpoint"
  description             = "DocumentDB Elastic cluster endpoint."
  recovery_window_in_days = 7

  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "secret_management" }))

  depends_on = [aws_docdbelastic_cluster.this]
}

resource "aws_secretsmanager_secret_version" "endpoint" {
  secret_id     = aws_secretsmanager_secret.endpoint.id
  secret_string = aws_docdbelastic_cluster.this.endpoint
}
