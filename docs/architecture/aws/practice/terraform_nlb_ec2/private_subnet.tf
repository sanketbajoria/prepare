/*
  Public Subnet and route table association
*/
resource "aws_subnet" "private_subnet_1a" {
  vpc_id = aws_vpc.practice_vpc.id

  cidr_block        = var.private_subnet_cidr_1a
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "private_subnet_1a"
  }
}

resource "aws_subnet" "private_subnet_1b" {
  vpc_id = aws_vpc.practice_vpc.id

  cidr_block        = var.private_subnet_cidr_1b
  availability_zone = "${var.aws_region}b"

  tags = {
    Name = "private_subnet_1b"
  }
}
