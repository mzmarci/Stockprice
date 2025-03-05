output "public_subnets_id" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public_subnets[*].id
}

# output "public_subnet_azs" {
#   value = [for s in aws_subnet.public_subnets : s.availability_zone]
# }

output "public_subnet_azs" {
  value = aws_subnet.public_subnets[*].availability_zone
}


output "private_subnets_id" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private_subnets[*].id
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.stock_vpc.id
}

output "azs" {
  value = data.aws_availability_zones.available_zones.names
}
