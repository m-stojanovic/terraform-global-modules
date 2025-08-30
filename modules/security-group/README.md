# Usage

```
module "security_group" {
  source = "git::ssh://bitbucket.org/devops/terraform-global-modules.git//security-group"

  for_each = local.security_groups
  name     = each.key
  vpc_id   = module.network.vpc_id

  ingress_with_cidr_blocks = each.value.ingress_with_cidr_blocks
  egress_with_cidr_blocks  = each.value.egress_with_cidr_blocks

  tags = var.tags
}

locals {
  security_groups = {
    "${var.project}-${var.environment}-example-sg" = {
      ingress_with_cidr_blocks = [
        {
          from_port   = var.port
          to_port     = var.port
          protocol    = "tcp"
          cidr_blocks = module.network.vpc_cidr_block
        },
      ]
      egress_with_cidr_blocks = [
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = "0.0.0.0/0"
        }
      ]
    }
  }
}
```