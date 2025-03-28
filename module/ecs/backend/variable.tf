variable "ecs_task_execution_role_arn" {
    description = "ECS task excution role ARN"
    type = string
}
variable "ecs_task_role_arn" {}

variable "ecr_repo_urls" {
  description = "Map of ECR repository URLs"
  type        = string
}

variable "desired_count" {}

variable "container_image" {}

variable "ecs_task_deployment_minimum_healthy_percent" {
  description = "How many percent of a service must be running to still execute a safe deployment"
  default     = 50
  type        = number
}

variable "ecs_task_deployment_maximum_percent" {
  description = "How many additional tasks are allowed to run (in percent) while a deployment is executed"
  default     = 100
  type        = number
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID for ECS tasks"
  type        = string
}

variable "backend_target_group_arn" {
  description = "List of target group ARNs"
  type        = string
}