# Application Load Balancer (ALB) for frontend & middle
resource "aws_lb" "stock_alb" {
  name               = var.alb_name
  internal           = false  
  load_balancer_type = "application"
  security_groups    = var.alb_security_group_id
  subnets            = var.public_subnets_id
  enable_deletion_protection = false

  tags = {
    Name = var.alb_name
  }
}

# Network Load Balancer (NLB) for backend (Redis)
resource "aws_lb" "stock_nlb" {
  name               = var.nlb_name
  internal           = true  
  load_balancer_type = "network"
  subnets            = var.private_subnets_id
}

# ALB Listeners
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.stock_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_lb_listener" "middle_listener" {
  load_balancer_arn = aws_lb.stock_alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.middle_tg.arn
  }
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.stock_nlb.arn
  port              = 8000
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

# Frontend Target Group
resource "aws_lb_target_group" "frontend_tg" {
  name        = "${var.alb_name}-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }
}

# Middle Layer Target Group
resource "aws_lb_target_group" "middle_tg" {
  name        = "${var.alb_name}-middle-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }
}

# Backend Target Group (Redis)
resource "aws_lb_target_group" "backend_tg" {
  name        = "${var.nlb_name}-backend-tg"
  port        = 8000
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip" 

  # REMOVED HEALTH CHECK since TCP doesn't support HTTP-based checks
}

# Auto Scaling Target Group
resource "aws_lb_target_group" "asg_tg" {
  name        = "${var.alb_name}-asg-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    matcher             = "200-299" 
  }
  lifecycle {
    create_before_destroy = true
  }
}

# create a listener for asg

resource "aws_lb_listener_rule" "asg_listener" {
  listener_arn = aws_lb_listener.frontend_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg_tg.arn
  }
  condition {
    path_pattern {
      values = ["/api"]
    }
  }
}


# ASG Launch Template
resource "aws_launch_template" "stock" {
  name_prefix   = var.alb_name
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_group_id
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = var.alb_name
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "stock_asg" {
  vpc_zone_identifier  = var.private_subnets_id # Ensure it's a list
  desired_capacity     = var.desired_capacity
  min_size            = var.min_size
  max_size            = var.max_size
  health_check_type   = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.stock.id
    version = aws_launch_template.stock.latest_version
  }

  target_group_arns = [aws_lb_target_group.asg_tg.arn]
}

# Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale_up"
  scaling_adjustment     = var.scale_up_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_cooldown
  autoscaling_group_name = aws_autoscaling_group.stock_asg.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale_down"
  scaling_adjustment     = var.scale_down_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown               = var.scale_cooldown
  autoscaling_group_name = aws_autoscaling_group.stock_asg.name
}