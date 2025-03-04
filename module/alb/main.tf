# created an application load balancer
//data "aws_availability_zones" "available_zones" {}

resource "aws_lb" "stock_lb" {
  name               = var.alb_name
  internal           = false  
  load_balancer_type = "application"
  security_groups    = [var.lb_security_group_id]
  subnets           = var.public_subnets_id

  enable_deletion_protection = false

  tags = {
    Name = var.name
  }
}

resource "aws_lb_listener" "stock_listener" {
  load_balancer_arn = aws_lb.stock_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "stock_listener_2" {
  load_balancer_arn = aws_lb.stock_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.stock_tg.arn
  }
}

resource "aws_lb_target_group" "stock_tg" {
  name     = "${var.lb_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }
}

resource "aws_lb_target_group" "middle" {
  name     = "${var.lb_name}-tg-middle"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }
}

resource "aws_launch_template" "stock" {
  name_prefix   = var.alb_name
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_group_id
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.name
    }
  }
}

resource "aws_autoscaling_group" "stock_scaling" {
  vpc_zone_identifier  = var.vpc_zone_identifier
  desired_capacity     = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  health_check_type   = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.stock.id
    version = "$Latest"
  }

  target_group_arns = var.target_group_arns
}

# Scaling policies
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  scaling_adjustment     = var.scale_up_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_cooldown
  autoscaling_group_name = aws_autoscaling_group.stock_scaling.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down"
  scaling_adjustment     = var.scale_down_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_cooldown
  autoscaling_group_name = aws_autoscaling_group.stock_scaling.name
}