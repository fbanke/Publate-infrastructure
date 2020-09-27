resource "aws_route53_zone" "primary" {
  name = var.dns_zone
}

resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = var.api_domain
  type    = "CNAME"
  ttl     = "300"
  records = [var.load_balancer]
}

resource "aws_route53_record" "local" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "local.${var.dns_zone}"
  type    = "A"
  ttl     = "300"
  records = ["127.0.0.1"]
}
