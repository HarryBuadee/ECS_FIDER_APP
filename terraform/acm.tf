# --------------------------------------------------
# Existing ACM Certificate
# --------------------------------------------------

data "aws_acm_certificate" "fider" {
  domain   = var.domain_name
  statuses = ["ISSUED"]

  most_recent = true
}
