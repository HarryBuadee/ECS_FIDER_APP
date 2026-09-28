# -------------------------
# VPC
# -------------------------

resource "aws_vpc" "fider_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Fider-VPC"
  }
}

# -------------------------
# Internet Gateway
# -------------------------

resource "aws_internet_gateway" "fider_igw" {
  vpc_id = aws_vpc.fider_vpc.id

  tags = {
    Name = "fider-igw"
  }
}

# -------------------------
# Public Subnet 1
# -------------------------

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.fider_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.availability_zone_1
  map_public_ip_on_launch = false

  tags = {
    Name = "fider-public-1"
  }
}

# -------------------------
# Public Subnet 2
# -------------------------

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.fider_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.availability_zone_2
  map_public_ip_on_launch = false

  tags = {
    Name = "fider-public-2"
  }
}

# -------------------------
# Public Route Table
# -------------------------

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.fider_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fider_igw.id
  }

  tags = {
    Name = "fider-public-rt"
  }
}

# -------------------------
# Route Table Associations
# -------------------------

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}
