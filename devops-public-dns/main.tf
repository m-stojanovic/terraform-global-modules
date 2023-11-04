resource "aws_route53_record" "app_elb_public" {
  count   = var.devops_r53_enable ? 1 : 0
  zone_id = var.public_zone_id
  name    = "${var.app_name}${var.environment_number}"
  type    = "CNAME"
  ttl     = "5"
  records = [var.lb_dns_name]
}

resource "aws_route53_record" "ls_app_alb_public" {
  count   = var.lsuk_r53_enable ? 1 : 0
  zone_id = var.ls_public_zone_id
  name    = "${var.app_name}${var.environment_number}"
  type    = "CNAME"
  ttl     = "5"
  records = [var.lb_dns_name]
}

resource "aws_route53_record" "lsie_app_alb_public" {
  count   = var.lsie_r53_enable ? 1 : 0
  zone_id = var.lsie_public_zone_id
  name    = "${var.app_name}${var.environment_number}"
  type    = "CNAME"
  ttl     = "5"
  records = [var.lb_dns_name]
}

resource "cloudflare_record" "cloudflare_app_elb_public" {
  count   = var.devops_cf_enable ? 1 : 0
  zone_id = var.devops_zone_id
  name    = "${var.app_name}${var.environment_number}"
  value   = var.lb_dns_name
  type    = "CNAME"
  proxied = var.proxy_enable
}

resource "cloudflare_record" "cloudflare_app_ls_uk_elb_public" {
  count   = var.lsuk_cf_enable ? 1 : 0
  zone_id = var.lsuk_zone_id
  name    = "${var.app_name}${var.environment_number}"
  value   = var.lb_dns_name
  type    = "CNAME"
  proxied = var.proxy_enable
}

resource "cloudflare_record" "cloudflare_app_ls_ie_elb_public" {
  count   = var.lsie_cf_enable ? 1 : 0
  zone_id = var.lsie_zone_id
  name    = "${var.app_name}${var.environment_number}"
  value   = var.lb_dns_name
  type    = "CNAME"
  proxied = var.proxy_enable
}
