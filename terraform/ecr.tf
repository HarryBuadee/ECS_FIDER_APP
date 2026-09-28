# --------------------------------------------------
# ECR Repository
# Stores the Fider Docker image
# --------------------------------------------------

resource "aws_ecr_repository" "fider" {
  name                 = "fider-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "fider-app"
  }
}
