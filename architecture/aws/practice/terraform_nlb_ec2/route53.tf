resource "aws_route53_record" "practice" {
  zone_id = var.zone_id
  name    = "practice.relayhub.pitneycloud.com"
  type    = "A"
  alias {
    name                   = aws_lb.practice_lb.dns_name
    zone_id                = aws_lb.practice_lb.zone_id
    evaluate_target_health = true
  }
}