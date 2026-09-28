



# --------------------------------------------------
# Existing Fider Database Secret
# --------------------------------------------------

data "aws_secretsmanager_secret" "database_url" {
  name = "fider/database-url"
}
# --------------------------------------------------
# Fider JWT Secret
# --------------------------------------------------

resource "random_password" "jwt_secret" {
  length  = 64
  special = false
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name = "fider/jwt-secret-terraform"

  tags = {
    Name = "fider-jwt-secret"
  }
}

resource "aws_secretsmanager_secret_version" "jwt_secret" {
  secret_id = aws_secretsmanager_secret.jwt_secret.id

  secret_string = jsonencode({
    JWT_SECRET = random_password.jwt_secret.result
  })
}
