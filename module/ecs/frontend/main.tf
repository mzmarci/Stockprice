# create a cluster 

resource "aws_ecs_cluster" "stockfrontend_cluster" {
  name = "stockfrontend_cluster"
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
          "containerPort": 80,
          "hostPort": 80
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
    target_group_arn = var.frontend_target_group_arn
    container_name   = "frontend"
    container_port   = 80
  }


  lifecycle {
    ignore_changes = [task_definition, desired_count]
    create_before_destroy = true  # Ensure service replacement is smooth
  }
}