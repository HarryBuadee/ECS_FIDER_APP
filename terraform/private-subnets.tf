# --------------------------------------------------
# Private RDS Subnets
# --------------------------------------------------

resource "aws_subnet" "private_db_1" {
  vpc_id            = aws_vpc.fider_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "eu-west-2a"

  map_public_ip_on_launch = false

  tags = {
    Name = "fider-private-db-1"
  }
}

resource "aws_subnet" "private_db_2" {
  vpc_id            = aws_vpc.fider_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "eu-west-2b"

  map_public_ip_on_launch = false

  tags = {
    Name = "fider-private-db-2"
  }
}
