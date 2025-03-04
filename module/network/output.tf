output "public_subnets_id" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public_subnets[*].id
}

output "private_subnets_id" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private_subnets[*].id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.stock_vpc.id
}
