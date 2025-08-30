module "route53" {
  source  = "terraform-aws-modules/route53/aws//modules/zones"
  version = "4.1.0"

  zones = var.zones
  tags  = var.tags
}
