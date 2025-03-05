
resource "aws_vpc" "stock_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "stock-demo"
  }
}

# Public subnets
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnet_cidrs)
  vpc_id            = aws_vpc.stock_vpc.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = element(data.aws_availability_zones.available_zones.names, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "Stock Public Subnet ${count.index + 1} "
  }
}

resource "aws_internet_gateway" "stock_igw" {
  vpc_id = aws_vpc.stock_vpc.id

  tags = {
    Name = "stock igw"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.stock_vpc.id

  tags = {
    Name = " Stock Public RouteTable"
  }
}

resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_route_table.id
  gateway_id             = aws_internet_gateway.stock_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_route_association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id 
  route_table_id = aws_route_table.public_route_table.id
}


# NAT Gateway and Private Subnets
resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name = "NAT EIP FOR STOCK"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "NAT Gateway ${count.index + 1}"
  }
}

# Private subnets
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.stock_vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = element(data.aws_availability_zones.available_zones.names, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

resource "aws_route_table" "private_route_table" {
  count = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.stock_vpc.id

  tags = {
    Name = "Private Route Table ${count.index + 1}"
  }
}

resource "aws_route" "private_route" {
  count                = length(var.private_subnet_cidrs)
  route_table_id       = aws_route_table.private_route_table[count.index].id
  nat_gateway_id       = aws_nat_gateway.nat_gateway[0].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_route_association" {
  count       = length(var.private_subnet_cidrs)
  subnet_id   = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}