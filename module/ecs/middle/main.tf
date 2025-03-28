resource "aws_ecs_cluster" "stockmiddleend_cluster" {
  name = "stockmiddleend_cluster"
}

resource "aws_ecs_task_definition" "middle_task" {
  family                   = "middle-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "middle",
      "image": "${var.ecr_repo_urls}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080
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

# ECS Service for middle layer
resource "aws_ecs_service" "middle_service1" {
  name            = "middle-service1"
  cluster         = aws_ecs_cluster.stockmiddleend_cluster.id
  task_definition = aws_ecs_task_definition.middle_task.arn
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
    target_group_arn = var.middle_target_group_arn
    container_name   = "middle"
    container_port   = 8080
  }

  depends_on = [aws_ecs_task_definition.middle_task]

  lifecycle {
    ignore_changes = [ task_definition, desired_count ]
    create_before_destroy = true  # Ensure service replacement is smooth
  }
}