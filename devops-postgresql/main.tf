resource "aws_security_group" "db_access_sg" {
  name        = "${var.environment_name}_${var.name_tag}_sg"
  description = "${var.environment_name}_${var.name_tag} PostgreSQL DB access security group"

  vpc_id = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    cidr_blocks     = var.cidr_blocks
    security_groups = var.security_groups
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_name} ${var.name_tag} postgresql sg"
  }
}

resource "aws_db_instance" "postgresql" {
  allocated_storage          = var.allocated_storage
  max_allocated_storage      = try(var.max_allocated_storage, null)
  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  backup_retention_period    = var.backup_retention_period
  copy_tags_to_snapshot      = var.copy_tags_to_snapshot
  db_subnet_group_name       = var.db_subnet_group_name
  deletion_protection        = var.deletion_protection
  engine                     = "postgres"
  engine_version             = var.engine_version
  final_snapshot_identifier  = var.final_snapshot_identifier
  identifier                 = var.db_identifier
  instance_class             = var.db_class
  password                   = var.password
  license_model              = "postgresql-license"
  monitoring_interval        = var.monitoring_interval
  monitoring_role_arn        = var.monitoring_role_arn
  multi_az                   = var.multi_az
  option_group_name          = var.option_group_name
  parameter_group_name       = var.parameter_group_name
  skip_final_snapshot        = var.skip_final_snapshot
  snapshot_identifier        = var.snapshot_id
  storage_type               = var.storage_type
  username                   = var.username
  ca_cert_identifier         = var.ca_cert_identifier
  vpc_security_group_ids     = compact([aws_security_group.db_access_sg.id, var.db_security_groups])

  tags = {
    Name          = var.name_tag
    Environment   = var.environment_name
    Service       = "Postgresql"
    workload-type = var.workload_type_tag
  }

  lifecycle {
    ignore_changes = [snapshot_identifier]
  }
}
