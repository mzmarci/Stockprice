
## Create an ECS Cluster for each layer

resource "aws_ecs_cluster" "stockfrontend_cluster" {
  name = "stockfrontend_cluster"
}

resource "aws_ecs_cluster" "stockmiddleend_cluster" {
  name = "stockmiddleend_cluster"
}

resource "aws_ecs_cluster" "stockbackend_cluster" {
  name = "stockbackend_cluster"
}


resource "aws_ecs_task_definition" "frontend_task" {
  family                   = "frontend-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "frontend",
      "image": "${var.ecr_repo_urls}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "hostPort": ${var.container_port}
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

}

resource "aws_ecs_task_definition" "middle_task" {
  depends_on               = [aws_ecs_task_definition.frontend_task]  # Ensures sequential execution
  family                   = "middle-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "middle",
      "image": "${var.ecr_repo_urls}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container_port1},
          "hostPort": ${var.container_port1}
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

resource "aws_ecs_task_definition" "backend_task" {
  depends_on               = [aws_ecs_task_definition.middle_task]  # Ensures sequential execution
  family                   = "backend-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "backend",
      "image": "${var.ecr_repo_urls}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container_port2},
          "hostPort": ${var.container_port2}
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


# ECS Service for frontend
resource "aws_ecs_service" "frontend_service1" {
  name            = "frontend-service1"
  cluster         = aws_ecs_cluster.stockfrontend_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  launch_type     = "FARGATE"
  platform_version = "LATEST"
  scheduling_strategy = "REPLICA"
  desired_count   = var.desired_count
  deployment_minimum_healthy_percent = var.ecs_task_deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.ecs_task_deployment_maximum_percent
  

  network_configuration {
    subnets          = var.subnet_ids 
    security_groups  = [var.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "frontend"
    container_port   = 80
  }

  depends_on = [aws_ecs_task_definition.frontend_task]

  lifecycle {
    create_before_destroy = true  # Ensure service replacement is smooth
  }
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
    target_group_arn = var.target_group_arn
    container_name   = "middle"
    container_port   = 8080
  }

  depends_on = [aws_ecs_task_definition.middle_task]

  lifecycle {
    create_before_destroy = true  # Ensure service replacement is smooth
  }
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
    target_group_arn = var.target_group_arn
    container_name   = "backend"
    container_port   = 8000
  }

  depends_on = [aws_ecs_task_definition.backend_task]

  lifecycle {
    create_before_destroy = true  # Ensure service replacement is smooth
  }
}