output "ecs_task_execution_role_arn" {
  value = aws_iam_role.stock_task_execution_role.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.stock_ecs_service_role.arn
}