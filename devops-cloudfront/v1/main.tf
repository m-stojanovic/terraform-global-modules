resource "aws_cloudfront_distribution" "cfdistribution" {
  origin {
    domain_name         = var.s3_target
    origin_id           = var.s3_target
    connection_attempts = 3
    connection_timeout  = 10

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2", ]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.cf_description
  default_root_object = ""
  price_class         = var.cf_priceclass

  aliases = var.cf_alternate_domains

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.s3_target
    compress         = false

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = var.cf_protocol_ploicy
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.acm_cert_arn
    minimum_protocol_version       = "TLSv1.2_2021"
    ssl_support_method             = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Terraform = "true"
  }
}