module "elasticache" {
  source  = "terraform-aws-modules/elasticache/aws"
  version = "1.3.0"

  description          = "ElastiCache cluster for ${var.name} Data Store"
  replication_group_id = "${var.project}-${var.environment}-${var.name}-db"

  port                       = 6379
  node_type                  = var.node_type
  engine_version             = var.engine_version
  cluster_mode               = var.cluster_mode
  cluster_mode_enabled       = var.cluster_mode_enabled
  automatic_failover_enabled = var.cluster_mode_enabled || var.multi_az_enabled ? true : false
  transit_encryption_enabled = var.transit_encryption_enabled

  replicas_per_node_group = var.replicas_per_node_group
  num_node_groups         = var.num_node_groups
  subnet_ids              = var.subnet_ids
  multi_az_enabled        = var.multi_az_enabled

  create_parameter_group = var.create_parameter_group
  parameter_group_family = var.parameter_group_family
  parameter_group_name   = "${var.project}-${var.environment}-${var.name}-db-${var.parameter_group_family}"
  parameters             = var.parameters

  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window
  maintenance_window       = var.maintenance_window

  vpc_id                         = var.vpc_id
  create_security_group          = true
  security_group_name            = "${var.project}-${var.environment}-${var.name}-redis-sg"
  security_group_rules           = var.security_group_rules
  security_group_use_name_prefix = false
  security_group_tags            = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-${var.name}-redis-sg" }), tomap({ "${var.project}:TechnicalFunction" = "network" }))

  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "data_storage" }))
}

resource "aws_secretsmanager_secret" "this" {
  name                    = "data_storage/elasticache.${replace(var.name, "-", "_")}.endpoint"
  description             = "ElastiCache cluster endpoint."
  recovery_window_in_days = 7

  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "secret_management" }))

  depends_on = [module.elasticache]
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = module.elasticache.replication_group_configuration_endpoint_address
}
