resource "aws_security_group" "this" {
  name        = "${var.project}-${var.env}-${var.name}"
  description = "Security group to allow access to the RedShift cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    description = "allow internal access"
    cidr_blocks = var.full_access_cidrs
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    description = "allow external access to everywhere"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(tomap({ "Name" = "${var.project}-${var.env}-${var.name}" }), var.tags)

}

resource "aws_redshift_subnet_group" "this" {
  name       = "${var.project}-${var.env}-${var.name}"
  subnet_ids = var.subnet_ids

  tags = var.tags
}

resource "aws_redshift_cluster" "this" {
  cluster_identifier                  = "${var.project}-${var.env}-${var.name}"
  database_name                       = var.database_name
  master_username                     = var.master_username
  node_type                           = var.node_type
  cluster_type                        = var.cluster_type
  automated_snapshot_retention_period = var.automated_snapshot_retention_period
  number_of_nodes                     = var.number_of_nodes
  publicly_accessible                 = var.publicly_accessible
  skip_final_snapshot                 = var.skip_final_snapshot
  cluster_subnet_group_name           = aws_redshift_subnet_group.this.name
  vpc_security_group_ids              = [aws_security_group.this.id]
  tags                                = var.tags
}
