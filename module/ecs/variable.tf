
variable "ecr_repo_urls" {
  description = "Map of ECR repository URLs"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS tasks"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security Group ID for ECS tasks"
  type        = string
}

variable "container_image" {}
variable "desired_count" {}

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

variable "target_group_arn" {
  description = " this is the target group arn needed"
  type = string
}
variable "ecs_task_execution_role_arn" {}
variable "ecs_task_role_arn" {}

variable "container_port" {
  description = "Container Port"
  type        = number
  default     = 80
}


variable "container_port1" {
  description = "Container Port"
  type        = number
  default     = 8080
}

variable "container_port2" {
  description = "Container Port"
  type        = number
  default     = 8000
}