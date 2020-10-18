resource "aws_route53_zone" "primary" {
  name = var.dns_zone
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.api_domain
  type    = "A"
  
  alias {
    name = aws_cloudfront_distribution.api.domain_name
    zone_id = aws_cloudfront_distribution.api.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "local" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "local.${var.dns_zone}"
  type    = "A"
  ttl     = "300"
  records = ["127.0.0.1"]
}
