variable "ec2_ami" {
  description = "this is a variable to manage ec2_ami type"
  type        = string
  default     = "ami-0a7abae115fc0f825"
}

variable "ec2_instance_type" {
  description = "this is a variable to manage ec2_instance_type"
  type        = string
  default     = "t2.medium"
}

variable "ec2_key_name" {
  description = "this is a variable to manage ec2_key_name"
  type        = string
  default     = "assign1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  default = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}
variable "public_subnet_cidrs" {
  description = "Public Subnet CIDR values"
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "instance_count" {
  description = "The number of EC2 instances to create"
  type        = number
  default     = 2
}

# Target group variables
variable "target_group_name" {
  description = "The name of the ALB target group"
  type        = string
  default     = "phs-alb-tg"
}

variable "target_group_port" {
  description = "Port on which the target group listens"
  type        = number
  default     = 80
}


variable "health_check_path" {
  description = "Health check path for the ALB target group"
  type        = string
  default     = "/"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Number of successful health checks before considering an instance healthy"
  type        = number
  default     = 3
}

variable "unhealthy_threshold" {
  description = "Number of failed health checks before considering an instance unhealthy"
  type        = number
  default     = 3
}

# Listener variables
variable "listener_port" {
  description = "Port on which ALB listener listens"
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "Protocol for ALB listener"
  type        = string
  default     = "HTTP"
}

variable "min_size" {
  description = "Minimum number of instances in ASG"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum number of instances in ASG"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired capacity of instances in ASG"
  type        = number
  default     = 2
}

variable "health_check_grace_period" {
  description = "Grace period for ASG health checks (seconds)"
  type        = number
  default     = 300
}

variable "instance_tag_name" {
  description = "Tag for instances created by the ASG"
  type        = string
  default     = "phs-app-instance"
}

# Auto Scaling scaling policies
variable "scale_up_adjustment" {
  description = "Scaling adjustment for scaling up"
  type        = number
  default     = 1
}

variable "scale_down_adjustment" {
  description = "Scaling adjustment for scaling down"
  type        = number
  default     = -1
}

variable "scale_cooldown" {
  description = "Cooldown period between scaling actions (seconds)"
  type        = number
  default     = 300
}

variable "lb_name" {
  description = "Name of the Load Balancer"
  type        = string
  default     = "phs-algo-alb"
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "name" {
  description = "Name of the ASG"
  type        = string
  default     = "phs-alb"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
  default     = "phsadmin" # ✅ Valid (starts with a letter, no special characters)
}
