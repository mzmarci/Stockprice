variable "db_identifier" {}
variable "db_name" {}
variable "db_password" {}
variable "db_instance_class" {}
variable "allocated_storage" {}
variable "engine" {}
variable "engine_version" {}
variable "vpc_security_group_ids" {}
variable "subnet_ids" {}
variable "multi_az" {}

variable "db_username" {
  description = "Master username for RDS"
  type        = string
  default     = "phsadmin"  # ✅ Valid (starts with a letter, no special characters)
}
