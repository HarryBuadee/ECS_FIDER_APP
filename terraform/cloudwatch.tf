# --------------------------------------------------
# CloudWatch Log Group
# Stores logs from the Fider ECS container
# --------------------------------------------------

resource "aws_cloudwatch_log_group" "fider" {
  name              = "/ecs/fider"
  retention_in_days = 7

  tags = {
    Name = "fider-logs"
  }
}
