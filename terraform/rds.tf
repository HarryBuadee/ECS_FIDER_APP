# --------------------------------------------------
# RDS Subnet Group
# --------------------------------------------------

resource "aws_db_subnet_group" "fider" {
  name        = "fider-db-subnet-group"
  description = "Private subnets for Fider RDS"

  subnet_ids = [
    aws_subnet.private_db_1.id,
    aws_subnet.private_db_2.id
  ]

  tags = {
    Name = "fider-db-subnet-group"
  }
}

# --------------------------------------------------
# PostgreSQL RDS Database
# --------------------------------------------------

resource "aws_db_instance" "fider" {
  identifier = "fider-db"

  engine         = "postgres"
  instance_class = var.db_instance_class

  allocated_storage     = 20
  max_allocated_storage = 1000
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.db_username

  # Existing RDS credentials are managed separately
  # in AWS Secrets Manager.
  manage_master_user_password = false

  db_subnet_group_name = aws_db_subnet_group.fider.name

  vpc_security_group_ids = [
    aws_security_group.rds_sg.id
  ]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 1
  copy_tags_to_snapshot   = true

  performance_insights_enabled = true

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "fider-db"
  }
}
