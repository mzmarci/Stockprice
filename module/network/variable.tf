variable "vpc_cidr" {}



variable "public_subnet_cidrs" {
  description = "Public Subnet CIDR values"
  default = [
    "10.0.1.0/24", "10.0.2.0/24"
  ]
}

variable "tags" {}

variable "private_subnet_cidrs" {
  default = [
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

variable "vpc_security_group_ids" {}

variable "private_subnets_id" {}

variable "vpc_id" {}

variable "public_subnets_id" {}