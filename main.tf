provider "aws" {
  region = var.region
}

resource "aws_route53_zone" "primary" {
  name = var.dns_zone
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.api_domain
  type    = "CNAME"
  ttl     = "300"
  records = [var.load_balancer]
}