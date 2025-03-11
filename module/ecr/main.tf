resource "aws_ecr_repository" "ecr" {
  for_each = toset(var.ecr_repositories)
  name     = each.value
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = "KMS"
  }

  tags = {
    Name  = each.value
    Group = "test"
  }
}









# resource "aws_ecr_repository" "frontends_ecr" {
#   name      = "frontends_ecr"
#   image_tag_mutability = var.immutable_ecr_repositories == "prod" ? "MUTABLE" : "IMMUTABLE"
#   force_delete = true
#   image_scanning_configuration  {
#     scan_on_push = var.scan_on_push
#   }
  
#   encryption_configuration {
#     encryption_type = "KMS"
#   }
  
#   lifecycle {
#     ignore_changes = [name]  # Prevents Terraform from recreating it if already present
#   }
#   tags = {
#     Name = "frontend ECR Repo"
#     Group = "test"
#   }
# }

# resource "aws_ecr_repository" "middles_ecr" {
#   name      = "middles_ecr"
#   image_tag_mutability = var.immutable_ecr_repositories == "prod" ? "MUTABLE" : "IMMUTABLE"
#   force_delete = true
#   image_scanning_configuration  {
#     scan_on_push = var.scan_on_push
#   }
  
#   encryption_configuration {
#     encryption_type = "KMS"
#   }

#   lifecycle {
#     ignore_changes = [name]  # Prevents Terraform from recreating it if already present
#   }
#   tags = {
#     Name = "middle ECR Repo"
#     Group = "test"
#   }
# }

# resource "aws_ecr_repository" "backends_ecr" {
#   name      = "backends_ecr"
#   image_tag_mutability = var.immutable_ecr_repositories == "prod" ? "MUTABLE" : "IMMUTABLE"
#   force_delete = true
#   image_scanning_configuration  {
#     scan_on_push = var.scan_on_push
#   }
  
#   encryption_configuration {
#     encryption_type = "KMS"
#   }

#   lifecycle {
#     ignore_changes = [name]  # Prevents Terraform from recreating it if already present
#   }
#   tags = {
#     Name = "backend ECR Repo"
#     Group = "test"
#   }
# }

