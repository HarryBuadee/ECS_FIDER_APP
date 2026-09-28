# --------------------------------------------------
# Application Load Balancer
# --------------------------------------------------

resource "aws_lb" "fider" {
  name               = "fider-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  tags = {
    Name = "fider-alb"
  }
}

# --------------------------------------------------
# Fider Target Group
# --------------------------------------------------

resource "aws_lb_target_group" "fider" {
  name        = "fider-target-group"
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.fider_vpc.id

  health_check {
    enabled             = true
    path                = "/_health"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "fider-target-group"
  }
}


# --------------------------------------------------
# HTTP Listener - Redirect to HTTPS
# --------------------------------------------------

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.fider.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# --------------------------------------------------
# HTTPS Listener - Forward to Fider
# --------------------------------------------------

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.fider.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-Res-PQ-2025-09"
  certificate_arn   = data.aws_acm_certificate.fider.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fider.arn
  }
}
