resource "aws_ecs_cluster" "stockbackend_cluster" {
  name = "stockbackend_cluster"
}

resource "aws_ecs_task_definition" "backend_task" {
  # Ensures sequential execution
  family                   = "backend-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "backend",
      "image": "${var.ecr_repo_urls}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8000,
          "hostPort": 8000
        }
      ],
      "memory": 1024,
      "cpu": 512
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 1024
  cpu                      = 512
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn
}






# ECS Service for backend
resource "aws_ecs_service" "backend_service1" {
  name            = "backend-service1"
  cluster         = aws_ecs_cluster.stockbackend_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  launch_type     = "FARGATE"
  platform_version = "LATEST"
  scheduling_strategy = "REPLICA"
  desired_count   = var.desired_count
  deployment_minimum_healthy_percent = var.ecs_task_deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.ecs_task_deployment_maximum_percent

  network_configuration {
    subnets          = var.subnet_ids 
    security_groups  = [var.security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.backend_target_group_arn
    container_name   = "backend"
    container_port   = 8000
  }

  depends_on = [aws_ecs_task_definition.backend_task]

  lifecycle {
    ignore_changes = [ task_definition, desired_count ]
    create_before_destroy = true  # Ensure service replacement is smooth
  }
}