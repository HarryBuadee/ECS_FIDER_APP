# --------------------------------------------------
# Existing Route 53 Hosted Zone
# --------------------------------------------------

data "aws_route53_zone" "harrydev" {
  name         = "harrydev.net."
  private_zone = false
}



# --------------------------------------------------
# Fider DNS Record
# --------------------------------------------------

resource "aws_route53_record" "fider" {
  zone_id = data.aws_route53_zone.harrydev.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = "dualstack.${aws_lb.fider.dns_name}"
    zone_id                = aws_lb.fider.zone_id
    evaluate_target_health = true
  }
}
