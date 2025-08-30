module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  name = var.name
  cidr = var.cidr

  azs                           = var.azs
  private_subnets               = var.private_subnets
  public_subnets                = var.public_subnets
  manage_default_security_group = true
  manage_default_route_table    = var.manage_default_route_table
  default_security_group_name   = var.default_security_group_name

  enable_flow_log                      = var.enable_flow_log
  create_flow_log_cloudwatch_iam_role  = var.create_flow_log_cloudwatch_iam_role
  create_flow_log_cloudwatch_log_group = var.create_flow_log_cloudwatch_log_group
  flow_log_traffic_type                = var.flow_log_traffic_type

  enable_dns_hostnames    = true
  enable_dns_support      = true
  map_public_ip_on_launch = true

  enable_nat_gateway     = var.enable_nat_gateway
  single_nat_gateway     = var.single_nat_gateway
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  nat_gateway_tags       = var.tags
  igw_tags               = var.tags

  dhcp_options_tags        = var.tags
  default_route_table_tags = var.tags
  tags                     = var.tags

  private_subnet_tags = var.private_subnet_tags
  public_subnet_tags  = var.public_subnet_tags
}
