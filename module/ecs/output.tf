

output "frontend_cluster_id" {
  value = aws_ecs_cluster.frontend_cluster.id
}

output "middle_cluster_id" {
  value = aws_ecs_cluster.middle_cluster.id
}

output "backend_cluster_id" {
  value = aws_ecs_cluster.backend_cluster.id
}

output "frontend_task_definition_arn" {
  value = aws_ecs_task_definition.frontend_task.arn
}

output "middle_task_definition_arn" {
  value = aws_ecs_task_definition.middle_task.arn
}

output "backend_task_definition_arn" {
  value = aws_ecs_task_definition.backend_task.arn
}

output "frontend_service_name" {
  value = aws_ecs_service.frontend_service1.name
}

output "middle_service_name" {
  value = aws_ecs_service.middle_service1.name
}

output "backend_service_name" {
  value = aws_ecs_service.backend_service1.name
}