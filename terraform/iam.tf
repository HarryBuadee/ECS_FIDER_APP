# --------------------------------------------------
# ECS Task Execution Role
# Allows ECS to pull images, send logs and retrieve
# secrets required by the Fider container.
# --------------------------------------------------

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "fider-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "fider-ecs-task-execution-role"
  }
}

# Standard ECS task execution permissions:
# ECR image pulls and CloudWatch logging.

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --------------------------------------------------
# Secrets Manager permissions for ECS
# --------------------------------------------------

resource "aws_iam_role_policy" "ecs_secrets" {
  name = "fider-secrets-access"
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "secretsmanager:GetSecretValue"
        ]

        Resource = [
          aws_secretsmanager_secret.jwt_secret.arn,
          data.aws_secretsmanager_secret.database_url.arn
        ]

      }
    ]
  })
}





