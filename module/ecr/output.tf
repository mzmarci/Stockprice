output "ecr_repo_urls" {
  description = "ECR repository URLs"
  value = { for repo in aws_ecr_repository.ecr : repo.name => repo.repository_url }
}


