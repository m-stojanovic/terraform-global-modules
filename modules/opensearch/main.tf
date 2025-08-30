resource "random_password" "this" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "this" {
  name                    = "monitoring/opensearch.${var.domain_name}.credentials"
  description             = "OpenSearch master credentials"
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    "${var.project}:DataClassification" = "confidential",
    "${var.project}:TechnicalFunction"  = "secret_management",
    "${var.project}:ModuleName"         = "opensearch"
  })
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    username = var.master_user_name
    password = random_password.this.result
  })
}

module "opensearch" {
  source  = "terraform-aws-modules/opensearch/aws"
  version = "1.7.0"

  domain_name            = var.domain_name
  access_policies        = var.access_policies
  log_publishing_options = var.log_publishing_options

  cluster_config = {
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    dedicated_master_enabled = var.dedicated_master_enabled
    zone_awareness_enabled   = var.zone_awareness_enabled
  }

  ebs_options = {
    ebs_enabled = true
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  domain_endpoint_options = {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  advanced_security_options = {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options = {
      master_user_name     = var.master_user_name
      master_user_password = random_password.this.result
    }
  }

  auto_tune_options = {
    desired_state = var.auto_tune_desired_state
  }

  tags = merge(var.tags, {
    "${var.project}:DataClassification" = "confidential",
    "${var.project}:TechnicalFunction"  = "monitoring",
    "${var.project}:ModuleName"         = "opensearch"
  })
}
