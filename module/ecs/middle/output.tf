output "middle_cluster_id" {
  value = aws_ecs_cluster.stockmiddleend_cluster.id
}

output "middle_service_name" {
  value = aws_ecs_service.middle_service1.name
}

output "middle_task_definition_arn" {
  value = aws_ecs_task_definition.middle_task.arn
}