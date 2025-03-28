output "backend_cluster_id" {
  value = aws_ecs_cluster.stockbackend_cluster.id
}

output "backend_task_definition_arn" {
  value = aws_ecs_task_definition.backend_task.arn
}

output "backend_service_name" {
  value = aws_ecs_service.backend_service1.name
}