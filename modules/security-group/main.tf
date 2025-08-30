module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  use_name_prefix = var.use_name_prefix

  ingress_cidr_blocks      = var.ingress_cidr_blocks
  ingress_with_cidr_blocks = var.ingress_with_cidr_blocks
  ingress_rules            = var.ingress_rules

  egress_cidr_blocks      = var.egress_cidr_blocks
  egress_with_cidr_blocks = var.egress_with_cidr_blocks
  egress_rules            = var.egress_rules

  ingress_with_source_security_group_id = var.ingress_with_source_security_group_id
  egress_with_source_security_group_id  = var.egress_with_source_security_group_id

  tags = var.tags
}
