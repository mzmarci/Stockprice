output "lb_arn" {
  value = aws_lb.stock_alb.arn
}
output "nlb_arn" {
  value = aws_lb.stock_nlb.arn
}

output "lb_dns_name" {
  value = aws_lb.stock_alb.dns_name
}

output "frontend_target_group_arn" {
  value = aws_lb_target_group.frontend_tg.arn
}

output "middle_target_group_arn" {
  value = aws_lb_target_group.middle_tg.arn
}

output "backend_target_group_arn" {
  value = aws_lb_target_group.backend_tg.arn
}

output "ASG_target_group_arn" {
  value = aws_lb_target_group.asg_tg.arn
}

output "asg_name" {
  value = aws_autoscaling_group.stock_asg.name
}

