module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.8.0"

  name                   = var.name
  availability_zone      = var.availability_zone
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [module.ec2-sg.security_group_id]

  instance_type      = var.instance_type
  ami                = var.ami
  ignore_ami_changes = var.ignore_ami_changes
  instance_tags      = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-${var.name}", "${var.project}:TechnicalFunction" = "compute" }))

  create_eip                  = var.create_eip
  eip_tags                    = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-${var.name}-eip", "${var.project}:TechnicalFunction" = "network" }))
  create_iam_instance_profile = var.create_iam_instance_profile
  key_name                    = aws_key_pair.this.key_name

  user_data = var.user_data

  root_block_device  = var.root_block_device
  enable_volume_tags = true
  volume_tags        = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-${var.name}-volume", "${var.project}:TechnicalFunction" = "data_storage" }))

  tags = merge(var.tags, tomap({ "${var.project}:ModuleName" = "ec2" }))
}

resource "aws_key_pair" "this" {
  key_name   = "${var.project}-${var.environment}-${var.name}"
  public_key = file(var.public_key_path)

  tags = merge(var.tags, tomap({ "${var.project}:ModuleName" = "ec2", "${var.project}:TechnicalFunction" = "compute" }))
}

module "ec2-sg" {
  source = "git::ssh://git@bitbucket.org/devops/terraform-global-modules.git//modules/security-group"

  name        = "${var.project}-${var.environment}-${var.name}-ec2"
  description = "Allow Outbound traffic to everywhere."
  vpc_id      = var.vpc_id

  egress_with_cidr_blocks = concat([
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ], var.additional_egress_rules)

  ingress_with_cidr_blocks = concat([
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.vpn_cidr
      description = "Allow SSH from VPN"
    }
  ], var.additional_ingress_rules)

  tags = merge(var.tags, tomap({ "Name" = "${var.project}-${var.environment}-${var.name}-ec2-sg", "${var.project}:TechnicalFunction" = "network", "${var.project}:ModuleName" = "ec2" }))
}
