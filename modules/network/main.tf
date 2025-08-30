locals {
  vpc_peering_requests = {
    "${var.project}-${var.environment}-shared-ap-southeast-1" = {
      peer_vpc_id            = var.shared_vpc_id
      peer_region            = var.region
      peer_owner_id          = var.shared_aws_account_id
      destination_cidr_block = var.shared_vpc_cidr
    },
  }

  filtered_peering_requests = {
    for k, v in local.vpc_peering_requests :
    k => v if var.request_peering == true
  }
}

module "vpc" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/vpc"

  name                        = "${var.project}-${var.environment}-vpc"
  azs                         = var.azs
  cidr                        = var.cidr
  private_subnets             = var.private_subnets
  public_subnets              = var.public_subnets
  default_security_group_name = "${var.project}-${var.environment}-default"
  enable_nat_gateway          = var.enable_nat_gateway
  single_nat_gateway          = var.single_nat_gateway
  one_nat_gateway_per_az      = var.one_nat_gateway_per_az
  tags                        = var.tags

  # Tag private & public subnets for internal and internet-facing LB, as required by AWS Load Balancer Controller
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    "karpenter.sh/discovery"          = "${var.project}-${var.environment}-eks-cluster"
  }
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
}

module "vpc-peering-requestor" {

  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/vpc-peering-requestor"

  for_each = merge(local.filtered_peering_requests)

  name        = each.key
  project     = var.project
  peer_vpc_id = each.value.peer_vpc_id
  vpc_id      = module.vpc.vpc_id

  peer_region   = each.value.peer_region
  peer_owner_id = each.value.peer_owner_id

  route_table_ids        = module.vpc.private_route_table_ids
  destination_cidr_block = each.value.destination_cidr_block

  tags = var.tags

  depends_on = [module.vpc]
}

module "tls-sg" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/security-group"

  name        = "${var.project}-${var.environment}-tls-internal-sg"
  description = "Allow TLS inbound traffic from all internal networks"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/8"]
  ingress_rules       = ["https-443-tcp"]

  tags = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-tls-internal-sg" }))
}

data "aws_iam_policy_document" "generic_endpoint_policy" {
  statement {
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpc"

      values = [module.vpc.vpc_id]
    }
  }
}

module "vpc-endpoints" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/vpc/modules/vpc-endpoints"

  vpc_id = module.vpc.vpc_id
  # Default security group ids for endpoints
  security_group_ids = [module.tls-sg.security_group_id]

  endpoints = merge(var.vpc_endpoints, {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
      policy          = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags            = { Name = "${var.project}-${var.environment}-s3-ep" }
    },
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags                = { Name = "${var.project}-${var.environment}-ecr-api-ep" }
    },
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags                = { Name = "${var.project}-${var.environment}-ecr-dkr-ep" }
    },
    secretsmanager = {
      service             = "secretsmanager"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      policy              = data.aws_iam_policy_document.generic_endpoint_policy.json
      tags                = { Name = "${var.project}-${var.environment}-secretsmanager-ep" }
    }
  })

  tags = var.tags
}

#################  Requierd for all accounts #################

resource "aws_iam_account_password_policy" "password_policy" {
  allow_users_to_change_password = "true"
  hard_expiry                    = "false"
  minimum_password_length        = "14"
  max_password_age               = "90"
  password_reuse_prevention      = "24"
  require_lowercase_characters   = "true"
  require_numbers                = "true"
  require_symbols                = "true"
  require_uppercase_characters   = "true"
}
