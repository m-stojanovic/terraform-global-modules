resource "aws_db_subnet_group" "this" {
  name       = var.db_identifier
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "this" {

  name        = "${var.db_identifier}-sg"
  description = "${var.db_identifier} db access sg"

  vpc_id = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "allow access from vpc"
  }
  # ingress {
  #   from_port   = var.db_port
  #   to_port     = var.db_port
  #   protocol    = "tcp"
  #   cidr_blocks = ["${var.office_private_cidr}"]
  #   description = "allow access from office ips"
  # }
  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.allow_cidr
    description = "allow access to db"
  }
  egress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    description = "allow access from db"
    cidr_blocks = var.allow_cidr
  }
  egress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    description = "allow access from db to VPC"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
  # egress {
  #   from_port   = var.db_port
  #   to_port     = var.db_port
  #   protocol    = "tcp"
  #   description = "allow access from db to office ips"
  #   cidr_blocks = ["${var.office_private_cidr}"]
  # }
}

resource "aws_db_instance" "this" {
  allocated_storage                   = var.allocated_storage
  engine                              = var.engine
  engine_version                      = var.engine_version
  instance_class                      = var.db_class
  identifier                          = var.db_identifier
  db_name                             = var.db_name
  snapshot_identifier                 = var.snapshot_id
  multi_az                            = var.multi_az
  username                            = var.username
  manage_master_user_password         = var.manage_master_user_password
  db_subnet_group_name                = aws_db_subnet_group.this.id
  vpc_security_group_ids              = ["${aws_security_group.this.id}"]
  option_group_name                   = var.option_group_name
  parameter_group_name                = var.parameter_group_name
  license_model                       = var.license_model
  auto_minor_version_upgrade          = var.auto_minor_version_upgrade
  skip_final_snapshot                 = true
  tags                                = var.tags
  monitoring_interval                 = var.monitoring_interval
  monitoring_role_arn                 = var.monitoring_role_arn
  performance_insights_enabled        = var.performance_insights_enabled
  storage_encrypted                   = var.storage_encrypted
  iops                                = var.iops
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  backup_retention_period             = 7
  deletion_protection                 = var.deletion_protection
  copy_tags_to_snapshot               = var.copy_tags_to_snapshot
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
}

resource "aws_db_parameter_group" "this" {
  count  = var.create_parameter_group ? 1 : 0
  name   = var.db_parameter_group_name
  family = var.family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }
}