resource "aws_cloudfront_distribution" "api" {
  origin {
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2", "SSLv3", "TLSv1", "TLSv1.1"]
    }
    domain_name = aws_alb.main.dns_name
    origin_id = "ELB-${aws_alb.main.name}"
  }

  # If using route53 aliases for DNS we need to declare it here too, otherwise we'll get 403s.
  aliases = [var.api_domain]

  enabled             = true
  default_root_object = ""

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ELB-${aws_alb.main.name}"

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
      headers = [ "*" ]
    }

    viewer_protocol_policy = "allow-all"
  }
  
  price_class = "PriceClass_All"

  # This is required to be specified even if it's not used.
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.api_aws_acm_certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1"
    ssl_support_method             = "sni-only"
  }
}