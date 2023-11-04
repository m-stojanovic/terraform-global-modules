resource "aws_security_group" "redhsift_db_access_sg" {
  name        = "${var.environment_name}_${var.name_tag}_sg"
  description = "${var.environment_name}_${var.name_tag} Redshift DB access security group"

  vpc_id = var.vpc_id

  ingress {
    from_port       = 5439
    to_port         = 5439
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

resource "aws_redshift_cluster" "this" {
  cluster_identifier                  = var.cluster_identifier
  database_name                       = var.database_name
  master_username                     = var.master_username
  master_password                     = var.master_password
  node_type                           = var.node_type
  snapshot_identifier                 = var.snapshot_identifier
  encrypted                           = var.encrypted
  kms_key_id                          = var.kms_key_id
  cluster_type                        = var.cluster_type
  automated_snapshot_retention_period = var.automated_snapshot_retention_period
  number_of_nodes                     = var.number_of_nodes
  publicly_accessible                 = var.publicly_accessible
  skip_final_snapshot                 = var.skip_final_snapshot
  cluster_subnet_group_name           = var.subnet_group_name
  cluster_parameter_group_name        = var.cluster_parameter_group_name
  logging {
    enable               = true
    log_destination_type = "cloudwatch"
    log_exports          = ["connectionlog", "userlog", "useractivitylog"]
  }
  vpc_security_group_ids = compact(
    [
      aws_security_group.redhsift_db_access_sg.id,
      var.extra_security_groups,
    ],
  )
}
