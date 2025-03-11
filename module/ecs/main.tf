
## Create an ECS Cluster for each layer

resource "aws_ecs_cluster" "frontend_cluster" {
  name = "frontend_cluster"
}

resource "aws_ecs_cluster" "middle_cluster" {
  name = "middle_cluster"
}

resource "aws_ecs_cluster" "backend_cluster" {
  name = "backend_cluster"
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
}


# ECS Service for frontend
resource "aws_ecs_service" "frontend_service" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.frontend_cluster.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  launch_type     = "FARGATE"
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
resource "aws_ecs_service" "middle_service" {
  name            = "midllelayer-service"
  cluster         = aws_ecs_cluster.middle_cluster.id
  task_definition = aws_ecs_task_definition.middle_task.arn
  launch_type     = "FARGATE"
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
resource "aws_ecs_service" "backend_service" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.backend_cluster.id
  task_definition = aws_ecs_task_definition.backend_task.arn
  launch_type     = "FARGATE"
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