/*
  Public Subnet and route table association
*/
resource "aws_subnet" "public_subnet_1a" {
  vpc_id = aws_vpc.practice_vpc.id

  cidr_block        = var.public_subnet_cidr_1a
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "public_subnet_1a"
  }
}

resource "aws_subnet" "public_subnet_1b" {
  vpc_id = aws_vpc.practice_vpc.id

  cidr_block        = var.public_subnet_cidr_1b
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "public_subnet_1b"
  }
}


resource "aws_route_table" "public_route_1a" {
  vpc_id = aws_vpc.practice_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "public-route-1a"
  }
}

resource "aws_route_table_association" "public_route_association_1a" {
  subnet_id      = aws_subnet.public_subnet_1a.id
  route_table_id = aws_route_table.public_route_1a.id
}

resource "aws_route_table" "public_route_1b" {
  vpc_id = aws_vpc.practice_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "public-route-1b"
  }
}

resource "aws_route_table_association" "public_route_association_1b" {
  subnet_id      = aws_subnet.public_subnet_1b.id
  route_table_id = aws_route_table.public_route_1b.id
}
