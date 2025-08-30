module "route53" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "4.1.0"

  zone_name    = var.zone_name
  zone_id      = var.zone_id
  records      = var.records
  private_zone = var.private_zone
}
