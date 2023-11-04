#####
## Module to create a public zone and its NS and SOA records
#####

resource "aws_route53_zone" "this" {
  name = var.zone_name

  tags = {
    Environment = var.environment_name
    Domain      = var.domain
    Type        = "Public"
  }
}

resource "aws_route53_record" "this_ns_record" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.zone_name
  type    = "NS"
  ttl     = "300"
  records = [
    aws_route53_zone.this.name_servers[0],
    aws_route53_zone.this.name_servers[1],
    aws_route53_zone.this.name_servers[2],
    aws_route53_zone.this.name_servers[3],
  ]
}

resource "aws_route53_record" "this_soa_record" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.zone_name
  type    = "SOA"
  ttl     = "300"
  records = [
    "${aws_route53_zone.this.name_servers[0]}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}

