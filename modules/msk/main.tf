module "msk" {
  source  = "terraform-aws-modules/msk-kafka-cluster/aws"
  version = "2.13.0"

  name          = "${var.project}-${var.environment}-${var.name}-msk"
  kafka_version = var.kafka_version

  number_of_broker_nodes      = var.number_of_broker_nodes
  broker_node_instance_type   = var.broker_node_instance_type
  broker_node_client_subnets  = var.broker_node_client_subnets
  broker_node_security_groups = [module.msk-sg.security_group_id]

  configuration_server_properties        = var.configuration_server_properties
  configuration_description              = var.configuration_description
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days

  create_schema_registry = var.create_schema_registry
  schema_registries      = var.schema_registries
  schemas                = var.schemas

  enable_storage_autoscaling = var.enable_storage_autoscaling
  broker_node_storage_info = {
    ebs_storage_info = { volume_size = var.volume_size }
  }

  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "compute" }))
}

module "msk-sg" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/security-group"

  name        = "${var.project}-${var.environment}-${var.name}-msk-sg"
  description = "Allow Outbound traffic to everywhere."
  vpc_id      = var.vpc_id

  egress_with_cidr_blocks = concat([
    {
      from_port   = 2181
      to_port     = 2181
      protocol    = "tcp"
      cidr_blocks = var.vpc_cidr_block
    },
    {
      from_port   = 9094
      to_port     = 9094
      protocol    = "tcp"
      cidr_blocks = var.vpc_cidr_block
    },
    {
      from_port   = 2181
      to_port     = 2181
      protocol    = "tcp"
      cidr_blocks = var.vpn_private
    },
    {
      from_port   = 9094
      to_port     = 9094
      protocol    = "tcp"
      cidr_blocks = var.vpn_private
    }
  ], var.additional_egress_rules)

  ingress_with_cidr_blocks = concat([
    {
      from_port   = 2181
      to_port     = 2181
      protocol    = "tcp"
      cidr_blocks = var.vpc_cidr_block
    },
    {
      from_port   = 9094
      to_port     = 9094
      protocol    = "tcp"
      cidr_blocks = var.vpc_cidr_block
    },
    {
      from_port   = 2181
      to_port     = 2181
      protocol    = "tcp"
      cidr_blocks = var.vpn_private
    },
    {
      from_port   = 9094
      to_port     = 9094
      protocol    = "tcp"
      cidr_blocks = var.vpn_private
    }
  ], var.additional_ingress_rules)

  tags = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-${var.name}-msk-sg", "${var.project}:TechnicalFunction" = "network", "${var.project}:ModuleName" = "msk" }))
}

resource "aws_secretsmanager_secret" "endpoint" {
  name                    = "data_storage/msk.${var.name}.endpoint"
  description             = "MSK cluster endpoint."
  recovery_window_in_days = 7

  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "secret_management" }))

  depends_on = [module.msk]
}

resource "aws_secretsmanager_secret_version" "endpoint" {
  secret_id     = aws_secretsmanager_secret.endpoint.id
  secret_string = join(",", module.msk.bootstrap_brokers)
}

