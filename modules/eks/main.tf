data "aws_caller_identity" "this" {}

resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}

resource "aws_ebs_snapshot_block_public_access" "this" {
  state = "block-all-sharing"
}

################# EKS Cluster #################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.31.1"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  tags                            = var.tags
  vpc_id                          = var.vpc_id
  subnet_ids                      = var.subnet_ids
  cluster_endpoint_public_access  = var.cluster_endpoint_public_access
  cluster_endpoint_private_access = var.cluster_endpoint_private_access

  create_cloudwatch_log_group              = true
  enable_cluster_creator_admin_permissions = true
  enable_irsa                              = var.enable_irsa # creating aws_iam_openid_connect_provider

  # IRSA with eks-pod-identity-agent: By enabling the eks-pod-identity-agent add-on, we're ensuring that all IRSA-enabled service accounts (including ebs-csi-controller-sa) have their tokens managed more efficiently by EKS.
  # IRSA without eks-pod-identity-agent: This still works, but token handling is less optimized, which might affect scale or performance in larger clusters.
  cluster_addons = {
    coredns = {
      tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "compute" }))
    }
    eks-pod-identity-agent = {
      tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "compute" }))
    }
    kube-proxy = {
      tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "compute" }))
    }
    vpc-cni = {
      tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "compute" }))
    }
    aws-ebs-csi-driver = {
      service_account_role_arn = aws_iam_role.ebs_csi.arn
      tags                     = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "compute" }))
    }
    aws-efs-csi-driver = {
      service_account_role_arn = aws_iam_role.efs_csi.arn
      tags                     = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "compute" }))
    }
    aws-mountpoint-s3-csi-driver = {
      service_account_role_arn = aws_iam_role.s3_csi.arn
      tags                     = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "compute" }))
    }
  }

  # EKS creates third security group that is not managable by code. It contains dislikable naming convention: eks-cluster-sg-${my-cluster-uniqueid} . More details: https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
  create_cluster_security_group          = true  # creating main cluster SG. Name managed via parameter cluster_security_group_name. SG contains 1 inbound rule 443 port to Node Group SG 
  create_node_security_group             = true  # creating node SG. Name managed via parameter node_security_group_name
  cluster_security_group_use_name_prefix = false # default true , removing hashed values from SG
  node_security_group_use_name_prefix    = false # default true , removing hashed values from SG
  cluster_security_group_name            = "${var.project}-${var.environment}-eks-cluster-sg"
  node_security_group_name               = "${var.project}-${var.environment}-eks-cluster-node-sg"
  # Additional rules for SG that is created with the name from parameter cluster_security_group_name 
  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules
  node_security_group_additional_rules = merge(
    {
      lb_backend_sg = {
        description              = "Allow traffic from the LB backend Security Group"
        protocol                 = "-1"
        from_port                = 0
        to_port                  = 0
        type                     = "ingress"
        source_security_group_id = module.lb-backend-sg.security_group_id
      }
      self_access_80 = {
        description = "Node to node ingress on HTTP port"
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        type        = "ingress"
        self        = true
      }
  }, var.additional_node_ingress_rules)

  iam_role_use_name_prefix                  = false
  cluster_encryption_policy_use_name_prefix = false
  create_iam_role                           = true # creating EKS IAM Role. Name of the role managed in parameter iam_role_name
  iam_role_name                             = "${var.project}-${var.environment}-eks-cluster"
  # we can add additional policies to created eks cluster iam role
  #iam_role_additional_policies = {} # e.g. AmazonEKSServicePolicy

  cluster_encryption_policy_name   = "${var.project}-${var.environment}-eks-cluster-encryption"
  attach_cluster_encryption_policy = true # attaching a policy to cluster role to manage KMS key alias created in KMS module. If cluster_encryption_config is set to {} this parameter is automatically ignored.
  kms_key_enable_default_policy    = true # enabling default KMS policy 
  cluster_encryption_config = {           # enabling default cluster encryption for secrets with kms. Disable by setting the value to {}
    resources = ["secrets"]
  }

  iam_role_tags = {
    "${var.project}:TechnicalFunction" = "access_management"
  }
  cloudwatch_log_group_tags = {
    "${var.project}:TechnicalFunction" = "monitoring"
  }
  cluster_security_group_tags = {
    "${var.project}:TechnicalFunction" = "network"
  }
  node_security_group_tags = {
    "${var.project}:TechnicalFunction" = "network"
    "karpenter.sh/discovery"           = "${var.project}-${var.environment}-eks-cluster"
  }
  cluster_encryption_policy_tags = {
    "${var.project}:TechnicalFunction" = "access_management"
  }
  cluster_tags = {
    "${var.project}:TechnicalFunction" = "compute"
  }

  # Managed node groups handle the lifecycle of each worker node for you. A managed node group will come with all the prerequisite software and permissions, 
  # connect itself to the cluster, provide an easier experience for lifecycle actions like autoscaling and updates.
  # check user data if needed, and instance profile
  eks_managed_node_groups = {
    "${var.project}-${var.environment}" = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = var.instance_types

      min_size                               = var.min_size
      max_size                               = var.max_size
      desired_size                           = var.desired_size
      launch_template_use_name_prefix        = false
      update_launch_template_default_version = var.update_launch_template_default_version
      enable_monitoring                      = true
      ebs_optimized                          = var.ebs_optimized # if workloads heavily rely on persistent storage from EBS volumes set this to true
      iam_role_use_name_prefix               = false
      platform                               = "linux"
      launch_template_tags                   = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "compute" }))
      iam_role_additional_policies = {
        "policy_1" = aws_iam_policy.node.arn
      }

      iam_role_tags = {
        "${var.project}:TechnicalFunction" = "access_management"
      }

      maintenance_options = {
        auto_recovery = "default"
      }

      update_config = {
        max_unavailable_percentage = var.max_unavailable_percentage
      }

      block_device_mappings = [
        {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.volume_size
            volume_type           = "gp3"
            delete_on_termination = true
            encrypted             = true
          }
        }
      ]
      labels = {
        dedicated = "kube-system"
      }
    }
  }
}

############## EBS Driver Add-on ##############

data "aws_iam_policy_document" "ebs_csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:kube-system:ebs-csi-controller-sa"
      ]
    }
    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "ebs_csi" {
  assume_role_policy = data.aws_iam_policy_document.ebs_csi.json
  name               = "${var.project}-${var.environment}-ebs-csi-driver"
  tags               = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}



############## EFS Driver Add-on ##############

data "aws_iam_policy_document" "efs_csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:kube-system:efs-csi-controller-sa"
      ]
    }
    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "efs_csi" {
  assume_role_policy = data.aws_iam_policy_document.efs_csi.json
  name               = "${var.project}-${var.environment}-efs-csi-driver"
  tags               = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))
}

resource "aws_iam_role_policy_attachment" "efs_csi" {
  role       = aws_iam_role.efs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}


############## S3 Driver Add-on ##############

data "aws_iam_policy_document" "s3_csi" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:kube-system:s3-csi-driver-sa"
      ]
    }
    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "s3_csi" {
  assume_role_policy = data.aws_iam_policy_document.s3_csi.json
  name               = "${var.project}-${var.environment}-s3-csi-driver"
  tags               = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))
}

resource "aws_iam_policy" "s3_csi" {
  name   = "${var.project}-${var.environment}-s3-csi-s3"
  policy = <<EOT
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "s3:Get*",
          "s3:List*"
        ],
        "Resource": "*"
      }
    ]
  }
  EOT
  tags   = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))
}

resource "aws_iam_role_policy_attachment" "s3_csi" {
  role       = aws_iam_role.s3_csi.name
  policy_arn = aws_iam_policy.s3_csi.arn
}

########### External Secret Operator ###########

data "aws_iam_policy_document" "eso" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:default:infra-on-${var.environment}-external-secrets"
      ]
    }
    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eso" {
  assume_role_policy = data.aws_iam_policy_document.eso.json
  name               = "${var.project}-${var.environment}-eso"
  tags               = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))
}

resource "aws_iam_role_policy_attachment" "eso" {
  role       = aws_iam_role.eso.name
  policy_arn = aws_iam_policy.eso.arn
}

resource "aws_iam_policy" "eso" {
  name = "${var.project}-${var.environment}-eso"
  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

############ EKS Node Policy ############

resource "aws_iam_policy" "node" {
  name = "${var.project}-${var.environment}-eks-node-custom-policy"
  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

################ ALB Controller ################

data "aws_iam_policy_document" "aws_lb_controller" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:infra-on-${var.environment}-aws-lb-controller"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "aws_lb_controller" {
  assume_role_policy = data.aws_iam_policy_document.aws_lb_controller.json
  name               = "${var.project}-${var.environment}-aws-lb-controller"
  tags               = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))
}

resource "aws_iam_role_policy_attachment" "aws_lb_controller" {
  role       = aws_iam_role.aws_lb_controller.name
  policy_arn = aws_iam_policy.aws_lb_controller.arn
}

resource "aws_iam_policy" "aws_lb_controller" {
  name   = "${var.project}-${var.environment}-aws-lb-controller"
  policy = file("${path.module}/policies/iam_lb_controller_policy.json")
  tags   = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))
}

################ External DNS ################

data "aws_iam_policy_document" "external_dns" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:infra-on-${var.environment}-external-dns"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "external_dns" {
  assume_role_policy = data.aws_iam_policy_document.external_dns.json
  name               = "${var.project}-${var.environment}-external-dns"
  tags               = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))
}

resource "aws_iam_role_policy_attachment" "external_dns" {
  role       = aws_iam_role.external_dns.name
  policy_arn = aws_iam_policy.external_dns.arn
}

resource "aws_iam_policy" "external_dns" {
  name   = "${var.project}-${var.environment}-external-dns"
  policy = file("${path.module}/policies/iam_external_dns_policy.json")
  tags   = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))
}

############### Karpenter ###############

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.31.1"

  cluster_name = module.eks.cluster_name

  enable_v1_permissions           = true # enable policy v1 that is used for karpenter versions > 1.0 
  create_pod_identity_association = true # enable karpenter service account in kube-system namespace to use the iam controller role
  enable_pod_identity             = true # enable karpenter iam controller role to access pods.eks.amazonaws.com
  enable_irsa                     = true # enable the oidc provider in iam controller role
  enable_spot_termination         = true # enable native spot termination handling # enabled by default 
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["kube-system:karpenter"]

  # karpenter iam controller role
  create_iam_role            = true
  iam_role_name              = "${var.project}-${var.environment}-karpenter-controller"
  iam_role_use_name_prefix   = false
  iam_policy_use_name_prefix = false
  iam_role_tags = {
    "${var.project}:TechnicalFunction" = "access_management"
  }
  iam_role_policies = {
    "Policy_1" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    "Policy_2" = aws_iam_policy.karpenter_policy_2.arn
  }

  # karpenter iam worker node role
  create_node_iam_role          = true
  node_iam_role_use_name_prefix = false
  node_iam_role_name            = "${var.project}-${var.environment}-karpenter-node-group"
  node_iam_role_tags = {
    "${var.project}:TechnicalFunction" = "access_management"
  }
  node_iam_role_additional_policies = { # additional iam policies for node iam role
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    "policy_2"                   = aws_iam_policy.node.arn
  }
  create_access_entry = true # enable karpenter-node-group role access entry 

  # append the mandatory name prefix to the cloudwatch rules
  # rules will end with random hash as we can not disable name prefix due to the module settings
  rule_name_prefix = "${var.project}-karpenter-"

  queue_name = "${var.project}-${var.environment}-karpenter-queue"

  tags = merge(var.tags, tomap({ "${var.project}:ModuleName" = "karpenter", "${var.project}:TechnicalFunction" = "not_supported" }))
}

# This policy is attached to the IAM role used by the Karpenter controller, granting it the necessary permissions to manage EC2 Spot Instances
resource "aws_iam_policy" "karpenter_policy_2" {
  name = "${var.project}-${var.environment}-karpenter-service-linked-role-ec2-spot-policy"
  path = "/"
  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:CreateServiceLinkedRole",
        ]
        Effect   = "Allow",
        Resource = "*",
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = "spot.amazonaws.com"
          }
        },
      }
    ]
  })
}

################ Grafana Loki ################
data "aws_iam_policy_document" "loki" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:addons:loki"]
    }

    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "loki" {
  assume_role_policy = data.aws_iam_policy_document.loki.json
  name               = "${var.project}-${var.environment}-loki"
  tags               = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))
}

resource "aws_iam_role_policy_attachment" "loki" {
  role       = aws_iam_role.loki.name
  policy_arn = aws_iam_policy.loki.arn
}

resource "aws_iam_policy" "loki" {
  name = "${var.project}-${var.environment}-loki-storage"
  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        Resource = [
          module.s3-bucket["${var.project}-${var.environment}-loki-chunks"].s3_bucket_arn,
          "${module.s3-bucket["${var.project}-${var.environment}-loki-chunks"].s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

############### S3 Buckets ###############
module "s3-bucket" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/s3-bucket"

  for_each                = local.buckets
  bucket                  = each.key
  block_public_acls       = each.value.block_public_acls
  block_public_policy     = each.value.block_public_policy
  ignore_public_acls      = each.value.ignore_public_acls
  restrict_public_buckets = each.value.restrict_public_buckets
  policy                  = try(each.value.policy, null)
  attach_policy           = try(each.value.attach_policy, false)
  cors_rule = try({
    rule = {
      id              = try(each.value.cors_rule.id, null)
      allowed_methods = each.value.cors_rule.allowed_methods
      allowed_origins = each.value.cors_rule.allowed_origins
      allowed_headers = try(each.value.cors_rule.allowed_headers, null)
      expose_headers  = try(each.value.cors_rule.expose_headers, null)
      max_age_seconds = try(each.value.cors_rule.max_age_seconds, null)
    }
  }, "")
  lifecycle_rule = try(each.value.lifecycle_rule, [])
  versioning = {
    enabled = each.value.versioning
  }
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = each.value.server_side_encryption_configuration.sse_algorithm
      }
    }
  }
  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "data_storage" }))
}

locals {
  default_empty_secrets = [
    "bitbucket/svc.techops.ssh.private.key"
  ]
  default_all_secrets = concat(local.default_empty_secrets, var.additional_empty_secrets)
  buckets = {
    "${var.project}-${var.environment}-loki-chunks" = {
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
      versioning              = false
      server_side_encryption_configuration = {
        sse_algorithm = "AES256"
      }
    }
  }
}

############### AWS Secrets ###############
resource "random_password" "grafana" {
  length  = 20
  special = false
}

resource "aws_secretsmanager_secret" "grafana" {
  name                    = "addons/grafana.credentials"
  description             = "Grafana username and password credentials."
  recovery_window_in_days = 7

  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "secret_management" }))
}

resource "aws_secretsmanager_secret_version" "grafana" {
  secret_id = aws_secretsmanager_secret.grafana.id
  secret_string = jsonencode({
    username = "${var.project}-grafana"
    password = random_password.grafana.result
  })
}

resource "aws_secretsmanager_secret" "slack" {
  name                    = "slack/svc.techops.webhook"
  description             = "Slack webhook for the grafana alerting"
  recovery_window_in_days = 7

  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "secret_management" }))
}

resource "aws_secretsmanager_secret" "this" {
  for_each                = toset(local.default_all_secrets)
  name                    = each.value
  description             = "Default empty secret generated by the EKS Module"
  recovery_window_in_days = 7
  tags                    = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "secret_management" }))
}

############ AWS LB Controller ############
module "lb-backend-sg" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/security-group"

  name        = "${var.project}-${var.environment}-lb-backend-controller-sg"
  description = "Allow Outbound traffic to everywhere. Is attached to {project}-{env}-eks-cluster-node-sg"
  vpc_id      = var.vpc_id

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  tags = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-lb-backend-controller-sg", "${var.project}:TechnicalFunction" = "network" }))
}

module "lb-frontend-sg" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/security-group"

  name        = "${var.project}-${var.environment}-lb-frontend-controller-sg"
  description = "Allows Inbound traffic to Load Balancer."
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = flatten(concat(
    [
      {
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        description = "Allow access from the VPN"
        cidr_blocks = var.vpn_public
      },
      {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        description = "Allow access from the VPN"
        cidr_blocks = var.vpn_public
      }
    ],
    [
      for rule in var.eks_lb_whitelisted_ingress_rules : [
        {
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          description = rule.description
          cidr_blocks = rule.cidr_blocks
        },
        {
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          description = rule.description
          cidr_blocks = rule.cidr_blocks
        }
      ]
    ]
  ))

  tags = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-lb-frontend-controller-sg", "${var.project}:TechnicalFunction" = "network" }))
}

############ AWS EFS ############
resource "aws_efs_file_system" "this" {
  for_each         = var.efs_configurations
  creation_token   = each.value.creation_token
  performance_mode = try(each.value.performance_mode, "generalPurpose")
  throughput_mode  = try(each.value.throughput_mode, "bursting")

  lifecycle_policy {
    transition_to_ia = each.value.transition_to_ia
  }

  tags = merge(var.tags, {
    "Name" = "${var.project}-${var.environment}-${each.value.creation_token}", "${var.project}:TechnicalFunction" = "data_storage"
  })
}

resource "aws_efs_mount_target" "az1" {
  for_each        = var.efs_configurations
  file_system_id  = aws_efs_file_system.this[each.key].id
  subnet_id       = var.subnet_ids[0]
  security_groups = [module.efs-sg.security_group_id]
}

resource "aws_efs_mount_target" "az2" {
  for_each        = var.efs_configurations
  file_system_id  = aws_efs_file_system.this[each.key].id
  subnet_id       = var.subnet_ids[1]
  security_groups = [module.efs-sg.security_group_id]
}

module "efs-sg" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/security-group"

  name        = "${var.project}-${var.environment}-efs-sg"
  description = "Allow communication between VPC and EFS"
  vpc_id      = var.vpc_id

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  ingress_with_cidr_blocks = [
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      cidr_blocks = var.vpc_cidr
    },
  ]

  tags = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-efs-sg", "${var.project}:TechnicalFunction" = "network" }))
}

############ Grafana CloudWatch datasource ############
data "aws_iam_policy_document" "cloudwatch_datasource" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values = [
        "system:serviceaccount:addons:grafana"
      ]
    }
    principals {
      identifiers = [module.eks.oidc_provider_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "cloudwatch_datasource" {
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_datasource.json
  name               = "${var.project}-${var.environment}-grafana-cloudwatch-datasource"
  tags               = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))
}

resource "aws_iam_policy" "cloudwatch_datasource" {
  name        = "${var.project}-${var.environment}-grafana-cloudwatch-datasource"
  description = "Allows Grafana to access CloudWatch metrics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowReadingMetricsFromCloudWatch"
        Effect = "Allow"
        Action = [
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetInsightRuleReport"
        ]
        Resource = "*"
      },
      {
        Sid      = "AllowReadingResourceMetricsFromPerformanceInsights"
        Effect   = "Allow"
        Action   = "pi:GetResourceMetrics"
        Resource = "*"
      },
      {
        Sid    = "AllowReadingLogsFromCloudWatch"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:GetLogGroupFields",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:GetLogEvents"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowReadingTagsInstancesRegionsFromEC2"
        Effect = "Allow"
        Action = [
          "ec2:DescribeTags",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions"
        ]
        Resource = "*"
      },
      {
        Sid      = "AllowReadingResourcesForTags"
        Effect   = "Allow"
        Action   = "tag:GetResources"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, tomap({ "${var.project}:TechnicalFunction" = "access_management" }))
}


resource "aws_iam_role_policy_attachment" "cloudwatch_datasource" {
  policy_arn = aws_iam_policy.cloudwatch_datasource.arn
  role       = aws_iam_role.cloudwatch_datasource.name
}
