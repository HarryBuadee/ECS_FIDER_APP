# --------------------------------------------------
# ECS Cluster
# --------------------------------------------------

resource "aws_ecs_cluster" "fider" {
  name = "Fider-Cluster"


  configuration {
    execute_command_configuration {
      logging = "DEFAULT"
    }
  }



  tags = {
    Name = "Fider-Cluster"
  }
}

# --------------------------------------------------
# ECS Task Definition
# --------------------------------------------------

resource "aws_ecs_task_definition" "fider" {
  family                   = "fider-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "1024"
  memory = "2048"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "Fider-app"
      image     = "${aws_ecr_repository.fider.repository_url}:v1"
      essential = true

      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "BASE_URL"
          value = "https://${var.domain_name}"
        }
      ]

      secrets = [
        {
          name      = "JWT_SECRET"
          valueFrom = "${aws_secretsmanager_secret.jwt_secret.arn}:JWT_SECRET::"
        },
        {
          name      = "DATABASE_URL"
          valueFrom = "${data.aws_secretsmanager_secret.database_url.arn}:DATABASE_URL::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.fider.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "fider-task"
  }
}

# --------------------------------------------------
# ECS Fargate Service
# --------------------------------------------------

resource "aws_ecs_service" "fider" {
  name            = "fider-service"
  cluster         = aws_ecs_cluster.fider.id
  task_definition = aws_ecs_task_definition.fider.arn
  desired_count   = 1
  launch_type     = "FARGATE"




  enable_ecs_managed_tags           = true
  health_check_grace_period_seconds = 60

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  network_configuration {
    subnets = [
      aws_subnet.public_subnet_1.id,
      aws_subnet.public_subnet_2.id
    ]

    security_groups = [
      aws_security_group.ecs_sg.id
    ]

    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.fider.arn
    container_name   = "Fider-app"
    container_port   = 3000
  }

  depends_on = [
    aws_lb_listener.https
  ]

  tags = {
    Name = "fider-service"
  }
}
