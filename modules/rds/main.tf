resource "random_password" "this" {
  length  = 20
  special = false
}

resource "aws_secretsmanager_secret" "this" {
  name                    = "data_storage/rds.${var.engine}.${var.name}.credentials"
  description             = "RDS Cluster username and password."
  recovery_window_in_days = 7

  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "secret_management" }))
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    username = var.username
    password = random_password.this.result
  })
}

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.10.0"

  identifier = "${var.project}-${var.environment}-${var.engine}-${var.name}"

  create_db_instance        = var.create_db_instance
  create_db_parameter_group = var.create_db_parameter_group
  create_db_option_group    = var.create_db_option_group

  engine            = var.engine
  engine_version    = var.engine_version
  family            = var.family
  instance_class    = var.instance_class
  storage_type      = var.storage_type
  iops              = var.iops
  storage_encrypted = var.storage_encrypted
  allocated_storage = var.allocated_storage
  kms_key_id        = var.kms_key_id

  db_name                     = var.db_name
  username                    = var.username
  password                    = random_password.this.result
  manage_master_user_password = false
  port                        = var.port

  multi_az                        = var.multi_az
  create_db_subnet_group          = var.create_db_subnet_group
  subnet_ids                      = var.subnet_ids
  db_subnet_group_name            = "${var.project}-${var.environment}-${var.engine}-${var.name}"
  db_subnet_group_use_name_prefix = false
  db_subnet_group_tags            = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "network" }))
  vpc_security_group_ids          = [module.security-group.security_group_id]

  apply_immediately          = var.apply_immediately
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window

  skip_final_snapshot              = var.skip_final_snapshot
  final_snapshot_identifier_prefix = var.final_snapshot_identifier_prefix
  deletion_protection              = var.deletion_protection
  copy_tags_to_snapshot            = true
  parameters                       = var.parameters
  parameter_group_name             = "${var.project}-${var.environment}-${var.engine}-${var.name}"
  parameter_group_use_name_prefix  = false
  db_parameter_group_tags          = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "data_storage" }))
  option_group_name                = "${var.project}-${var.environment}-${var.engine}-${var.name}"
  option_group_use_name_prefix     = false
  db_option_group_tags             = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "data_storage" }))

  create_cloudwatch_log_group            = var.create_cloudwatch_log_group
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  cloudwatch_log_group_tags              = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "monitoring" }))

  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "data_storage" }))
}

module "security-group" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/security-group"

  name        = "${var.project}-${var.environment}-rds-${var.name}"
  description = "Allow inbound traffic to RDS"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = concat([
    {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      description = "Allow inbound traffic from VPC"
      cidr_blocks = var.vpc_cidr
    },
    {
      from_port   = var.port
      to_port     = var.port
      protocol    = "tcp"
      description = "Allow inbound traffic from VPN"
      cidr_blocks = var.vpn_private
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

  tags = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-rds-${var.name}" }), tomap({ "${var.project}:TechnicalFunction" = "network" }))
}

resource "aws_secretsmanager_secret" "endpoint" {
  name                    = "data_storage/rds.${var.engine}.${var.name}.endpoint"
  description             = "RDS cluster endpoint."
  recovery_window_in_days = 7

  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "secret_management" }))

  depends_on = [module.rds]
}

resource "aws_secretsmanager_secret_version" "endpoint" {
  secret_id     = aws_secretsmanager_secret.endpoint.id
  secret_string = module.rds.db_instance_endpoint
}

resource "aws_secretsmanager_secret" "connection_string" {
  name                    = "data_storage/rds.${var.engine}.${var.name}.connection_string"
  description             = "RDS cluster connection string."
  recovery_window_in_days = 7

  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "secret_management" }))

  depends_on = [module.rds]
}

resource "aws_secretsmanager_secret_version" "connection_string" {
  secret_id = aws_secretsmanager_secret.connection_string.id

  secret_string = "${var.engine_full_name}://${var.username}:${random_password.this.result}@${module.rds.db_instance_endpoint}/${var.db_name}"
}
