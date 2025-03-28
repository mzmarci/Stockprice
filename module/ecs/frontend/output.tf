output "frontend_service_name" {
  description = "Frontend service name"  
  value = aws_ecs_service.frontend_service1.name
}

output "frontend_task_definition_arn" {
  value = aws_ecs_task_definition.frontend_task.arn
}

output "frontend_cluster_id" {
  value = aws_ecs_cluster.stockfrontend_cluster.id
}
