```
module "kafka" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/msk"

  name          = "general"
  kafka_version = "3.6.0"
  project       = var.project
  environment   = var.environment

  vpc_id         = module.network.vpc_id
  vpc_cidr_block = module.network.vpc_cidr_block

  number_of_broker_nodes     = 2
  broker_node_client_subnets = module.network.private_subnets
  broker_node_instance_type  = "kafka.t3.small"

  tags = merge(var.tags, tomap({ "${var.project}:ModuleName" = "msk" }))
}
```
