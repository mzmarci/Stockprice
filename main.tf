module "mainvpc" {
  source                 = "./module/network"
  public_subnet_cidrs    = var.public_subnet_cidrs
  private_subnet_cidrs   = var.private_subnet_cidrs
  vpc_cidr               = var.vpc_cidr
  vpc_security_group_ids = module.security_group.stock_security_group_id
  vpc_id                 = module.mainvpc.vpc_id
  public_subnets_id      = module.mainvpc.public_subnets_id[*]
  private_subnets_id     = module.mainvpc.private_subnets_id[*]

  tags = {
    Name = "Create VPC"
  }
}

module "security_group" {
  source = "./module/securitygroup"
  vpc_id = module.mainvpc.vpc_id
}

module "Bastion" {
  source                 = "./module/ec2"
  ec2_ami                = var.ec2_ami
  ec2_instance_type      = var.ec2_instance_type
  ec2_key_name           = var.ec2_key_name
  vpc_security_group_ids = [module.security_group.stock_security_group_id]
  public_subnets_id      = module.mainvpc.public_subnets_id
  user_data              = file("jenkin.sh")
}

module "load_balancer" {
  source               = "./module/alb"
  lb_name              = "phs-algo-alb"
  name                 = "phs-alb"
  ami_id               = var.ec2_ami
  target_group_arns    = [module.load_balancer.stock_tg_target_group_arn]
  instance_type        = var.ec2_instance_type
  environment          = var.environment
  vpc_id               = module.mainvpc.vpc_id
  public_subnets_id    = module.mainvpc.public_subnets_id
  vpc_zone_identifier  = module.mainvpc.private_subnets_id
  instance_tag_name    = "phs-app-instance"
  security_group_id    = [module.security_group.backend_security_group_id]
  alb_security_group_id = module.security_group.alb_security_group_id
  target_group_name    = "phs-alb-tg"
  //certificate_arn      = "arn:aws:acm:eu-west-1:723855297198:certificate/ed8cd6c8-d566-4a99-8e9e-593128a50a96"
//aws_acm_certificate.my_cert.arn
}

module "rds" {
  source                 = "./module/rds"
  db_identifier          = "phs-trading-db"
  db_name                = "marci"
  db_username            = "phsadmin"
  db_password            = var.db_password
  db_instance_class      = "db.t3.micro"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "17.2"
  vpc_security_group_ids = [module.security_group.backend_security_group_id]
  subnet_ids             = module.mainvpc.private_subnets_id
  multi_az               = true
}
