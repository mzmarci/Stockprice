## IAM Role for ECS Task Execution
resource "aws_iam_role" "stock_task_execution_role" {
  name = "StockTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach AWS Managed Policy for ECS Task Execution Role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_attach" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.stock_task_execution_role.name
}

## IAM Role for ECS Service (Application-Level Permissions)
resource "aws_iam_role" "stock_ecs_service_role" {
  name = "StockECSServicePermissions"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Custom IAM Policy for ECS Service Permissions
resource "aws_iam_policy" "stock_task_role" {
  name        = "StockECSServicePermissions"
  description = "Allow ECS to interact with ELB and IAM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:CreateService",
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeLoadBalancers",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach Custom IAM Policy to ECS Service Role 
resource "aws_iam_role_policy_attachment" "ecs_service_policy_attach" {
  policy_arn = aws_iam_policy.stock_task_role.arn
  role       = aws_iam_role.stock_ecs_service_role.name
}

## Allow ECS Task to Access S3
resource "aws_iam_policy" "stock_s3_access" {
  name        = "Stock_S3_Access"
  description = "Allow ECS tasks to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::workspacebucket-2023",
          "arn:aws:s3:::workspacebucket-2023/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_s3_attach" {
  policy_arn = aws_iam_policy.stock_s3_access.arn
  role       = aws_iam_role.stock_ecs_service_role.name
}

## Allow ECS Task to Access ECR
resource "aws_iam_policy" "ecs_ecr_access" {
  name        = "ECS_ECR_Access"
  description = "Allow ECS tasks to pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_ecr_attach" {
  policy_arn = aws_iam_policy.ecs_ecr_access.arn
  role       = aws_iam_role.stock_task_execution_role.name
}

## Allow ECS Task to Access ALB
resource "aws_iam_policy" "ecs_alb_access" {
  name        = "ECS_ALB_Access"
  description = "Allow ECS tasks to interact with ALB"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeLoadBalancers"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_alb_attach" {
  policy_arn = aws_iam_policy.ecs_alb_access.arn
  role       = aws_iam_role.stock_ecs_service_role.name
}
