# --------------------------------------------------
# ALB Security Group
# Internet -> ALB on HTTP/HTTPS
# --------------------------------------------------

resource "aws_security_group" "alb_sg" {
  name        = "fider-alb-sg"
  description = "Security group for Fider Application Load Balancer"
  vpc_id      = aws_vpc.fider_vpc.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fider-alb-sg"
  }
}

# --------------------------------------------------
# ECS Security Group
# ALB -> ECS on port 3000
# --------------------------------------------------

resource "aws_security_group" "ecs_sg" {
  name        = "fider-ecs-sg"
  description = "Security group for Fider ECS tasks"
  vpc_id      = aws_vpc.fider_vpc.id

  ingress {
    description     = "Fider application traffic from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fider-ecs-sg"
  }
}

# --------------------------------------------------
# RDS Security Group
# ECS -> PostgreSQL on port 5432
# --------------------------------------------------

resource "aws_security_group" "rds_sg" {
  name        = "fider-rds-sg"
  description = "Security group for Fider PostgreSQL RDS"
  vpc_id      = aws_vpc.fider_vpc.id

  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_sg.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fider-rds-sg"
  }
}
