resource "aws_db_subnet_group" "stock_rds_subnet" {
  name       = "${var.db_identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.db_identifier}-subnet-group"
  }
}

resource "aws_db_instance" "stock_rds" {
  identifier           = var.db_identifier
  engine              = var.engine
  engine_version      = var.engine_version
  instance_class      = var.db_instance_class
  allocated_storage   = var.allocated_storage
  db_name             = var.db_name
  username           = var.db_username
  password           = var.db_password
  multi_az           = var.multi_az
  publicly_accessible = false
  vpc_security_group_ids = var.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.stock_rds_subnet.name
  skip_final_snapshot    = true  # Change to false for production

  tags = {
    Name = var.db_identifier
  }
}