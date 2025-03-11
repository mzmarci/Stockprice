variable "scan_on_push" {
  type = bool
  description = "Enable image scanning on push"
  default = true
}

# variable "immutable_ecr_repositories" {
#   default = "prod"
# }


variable "ecr_repositories" {
  description = "List of ECR repositories to create"
  type        = list(string)
  default = ["frontend", "middle-layer", "backend"]
}

# variable "scan_on_push" {
#   description = "Enable image scanning on push"
#   type        = bool
#   default     = true
# }

# variable "expire_days" {
#   description = "Number of days before untagged images expire"
#   type        = number
#   default     = 14
# }

# variable "project_name" {
#   description = "Project name for tagging"
#   type        = string
#   default = "phs-algo-trading"
# }



# variable "erc_name" {
#   default = "ecr_repo"
# }



