provider "aws" {
  profile = "practice"
  region = var.aws_region
  skip_metadata_api_check = true
}

/*
    Default VPC
*/
resource "aws_vpc" "practice_vpc" {
  cidr_block           = var.CIDR
  enable_dns_support   = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  enable_classiclink   = "false"
  instance_tenancy     = "default"
  tags = {
    Name = "practice_vpc"
  }
}

/*
    Default Internet gateway
*/
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.practice_vpc.id
}
