output "public_dns" {
  value = aws_route53_record.app_elb_public.*.name
}