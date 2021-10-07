
variable "CIDR" {
  default = "10.1.0.0/16"
}

variable "public_subnet_cidr_1a" {
  description = "CIDR for the Public Subnet"
  default     = "10.1.0.0/24"
}

variable "public_subnet_cidr_1b" {
  description = "CIDR for the Public Subnet"
  default     = "10.1.4.0/24"
}

variable "private_subnet_cidr_1a" {
  description = "CIDR for the Private Subnet"
  default     = "10.1.8.0/24"
}

variable "private_subnet_cidr_1b" {
  description = "CIDR for the Private Subnet"
  default     = "10.1.12.0/24"
}

variable "ec2_instance_ami" {
  description = "EC2 Instance AMI"
  default     = "ami-01e7ca2ef94a0ae86"
}

variable "ec2_1a_instance_type" {
  description = "EC2 Instance Type"
  default     = "t3.micro"
}

variable "ec2_1b_instance_type" {
  description = "EC2 Instance Type"
  default     = "t3.micro"
}

variable "ec2_instance_count_1a"{
    default = 1
}

variable "ec2_instance_count_1b"{
    default = 1
}

variable "zone_id" {
  default = "ZXEYQ29OX0FVV"
}

variable "aws_region" {
    default = "us-east-2"
}

variable "backup" {
  default = false
}