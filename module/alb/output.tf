output "lb_arn" {
  value = aws_lb.stock_lb.arn
}

output "lb_dns_name" {
  value = aws_lb.stock_lb.dns_name
}

output "stock_tg_target_group_arn" {
  value = aws_lb_target_group.stock_tg.arn
}

output "middle_target_group_arn" {
  value = aws_lb_target_group.middle.arn
}

output "asg_name" {
  value = aws_autoscaling_group.stock_scaling.name
}
