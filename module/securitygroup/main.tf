locals {
  ports = [443, 80, 8000, 22, 8080, 9000, 3000, 9092]
}

resource "aws_security_group" "stock_security_group" {
  name        = "stock_security_group"
  description = "Allow SSH, HTTP, and other connections"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = local.ports
    content {
      description = "Allow traffic on port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]  # Allowing traffic from anywhere
    }
  }

  # Egress rule to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # "-1" means all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound traffic to any IP
  }

  tags = {
    Name = "stock security group"
  }
}

resource "aws_security_group" "lb_security_group" {
  name        = "lb_security_group"
  description = "Allow SSH and HTTP Connection"
  vpc_id      = var.vpc_id
 
  tags = {
    Name = "stock load balancer secuirty group"
  }

    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to internet
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to internet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

resource "aws_security_group" "web_sg" {   //frontend layer
  name        = "web_security_group"
  description = "Allow SSH and HTTP Connection"
  vpc_id      = var.vpc_id

  tags = {
    Name = "stock-web"
  }
}

resource "aws_security_group_rule" "web_ingress3" {
  security_group_id        = aws_security_group.web_sg.id
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb_security_group.id  # Allow traffic only from LB
}

resource "aws_security_group_rule" "web_ingress" {
  security_group_id        = aws_security_group.web_sg.id
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb_security_group.id  # Allow traffic only from LB
}

resource "aws_security_group_rule" "web_ingress1" {
  security_group_id        = aws_security_group.web_sg.id
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.lb_security_group.id  # Allow traffic only from LB
}

resource "aws_security_group_rule" "web-egress-rule" {
  security_group_id = aws_security_group.web_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]

}

# Middle Layer Security Group 

resource "aws_security_group" "middle_sg" {
  name        = "middle_security_group"
  description = "Allow traffic only from Web Servers"
  vpc_id      = var.vpc_id

}
resource "aws_security_group_rule" "middle-igress-rule" {
  security_group_id        = aws_security_group.middle_sg.id
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web_sg.id
}

resource "aws_security_group_rule" "middle-egress-rule" {  //only allow traffic to the backend
  security_group_id        = aws_security_group.middle_sg.id
  type                     = "egress"
  from_port                = 8000  # Redis port
  to_port                  = 8000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.backend_sg.id

}

# Backend Security Group (Attached to Redis)

resource "aws_security_group" "backend_sg" {
  name        = "backend_security_group"
  description = "Allow traffic only from Middle Layer"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "backend-igress-rule" {
  security_group_id        = aws_security_group.backend_sg.id
  type                     = "ingress"
  from_port                = 8000 # Redis default port
  to_port                  = 8000
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.middle_sg.id    # Only allow traffic from Middle Layer

}

// Restricted outbound traffic to only Middle Layer
resource "aws_security_group_rule" "backend-egress-rule" {
  security_group_id = aws_security_group.backend_sg.id
  type              = "egress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  source_security_group_id = aws_security_group.middle_sg.id
}