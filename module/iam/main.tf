## IAM Role for ECS Task execution

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

# Attach the required AWS managed policy for ECS task execution
resource "aws_iam_policy_attachment" "stock_task_execution_attach" {
  name       = "Stock-task-execution-attach"
  roles      = [aws_iam_role.stock_task_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

//Create ECS Task Role (ecsTaskRole)

resource "aws_iam_role" "stock_task_role" {
  name = "StockTaskRole"

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

// Allow Access to S3

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
  role       = aws_iam_role.stock_task_role.name
}