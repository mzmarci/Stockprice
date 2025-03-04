output "stock_security_group_id" {
  value =  aws_security_group.stock_security_group.id
}

output "alb_security_group_id" {
  value = aws_security_group.lb_security_group.id
}

output "web_security_group_id" {
  value = aws_security_group.web_sg.id
}

output "middle_security_group_id" {
  value = aws_security_group.middle_sg.id
}

output "backend_security_group_id" {
  value = aws_security_group.backend_sg.id
}

