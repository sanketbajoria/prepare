/*
    Security Group for API
*/

resource "aws_security_group" "ec2_sg" {
  name        = "ec2_sg"
  description = "Allow incoming Blocker SSR connections."
  vpc_id = aws_vpc.practice_vpc.id
  tags = {
    Name = "ec2_sg"
  }

  ingress {
    from_port = 80 # For http server
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22 # For ssh server
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["106.215.85.150/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "ec2_init" {
  template = file("ec2_init.tpl")
}

data "aws_iam_policy_document" "ec2_instances_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:*",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ec2_role_policy" {
  name   = "ec2_role_policy"
  role   = aws_iam_role.ec2_role.id
  policy = data.aws_iam_policy_document.ec2_instances_policy.json
}

resource "aws_iam_role" "ec2_role" {
  name               = "ec2_role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
EOF

}

resource "aws_iam_instance_profile" "ec2_profile" {
  name  = "ec2_profile"
  role = aws_iam_role.ec2_role.name
}

/*
    Create AWS instance
*/
resource "aws_instance" "ec2_1a" {
  count                       = var.ec2_instance_count_1a
  ami                         = var.ec2_instance_ami
  availability_zone           = "${var.aws_region}a"
  instance_type               = var.ec2_1a_instance_type
  key_name                    = aws_key_pair.practice_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  subnet_id                   = aws_subnet.public_subnet_1a.id
  source_dest_check           = false
  user_data                   = data.template_file.ec2_init.rendered
  associate_public_ip_address = true
  disable_api_termination     = false
  ebs_optimized               = true
  hibernation                 = false
  monitoring                  = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp2"
  }

  tags = {
    Name = "ec2_1a.${count.index}",
    Service = "ec2"
  }

  lifecycle {
    ignore_changes = [
     tags
    ]
    
  }
}

resource "aws_instance" "ec2_1a_back" {
  count                       = var.backup?var.ec2_instance_count_1a:0
  ami                         = var.ec2_instance_ami
  availability_zone           = "${var.aws_region}a"
  instance_type               = var.ec2_1a_instance_type
  key_name                    = aws_key_pair.practice_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  subnet_id                   = aws_subnet.public_subnet_1a.id
  source_dest_check           = false
  user_data                   = data.template_file.ec2_init.rendered
  associate_public_ip_address = true
  disable_api_termination     = false
  ebs_optimized               = true
  hibernation                 = false
  monitoring                  = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp2"
  }

  tags = {
    Name = "ec2_1a_back.${count.index}",
    Service = "ec2"
  }

  lifecycle {
    ignore_changes = [
     tags
    ]
    
  }
}

resource "aws_instance" "ec2_1b" {
  count                       = var.ec2_instance_count_1b
  ami                         = var.ec2_instance_ami
  availability_zone           = "${var.aws_region}b"
  instance_type               = var.ec2_1b_instance_type
  key_name                    = aws_key_pair.practice_key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  subnet_id                   = aws_subnet.public_subnet_1b.id
  source_dest_check           = false
  user_data                   = data.template_file.ec2_init.rendered
  associate_public_ip_address = true
  disable_api_termination     = false
  ebs_optimized               = true
  hibernation                 = false
  monitoring                  = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  root_block_device {
    delete_on_termination = true
    volume_size           = 8
    volume_type           = "gp2"
  }

  tags = {
    Name = "ec2_1b.${count.index}",
    Service = "ec2"
  }

  lifecycle {
    ignore_changes = [
     tags
    ]
  }
  
}


locals {
 ec2_instance_ids = concat(aws_instance.ec2_1a[*].id, aws_instance.ec2_1b[*].id)
 ec2_instance_back_ids = aws_instance.ec2_1a_back[*].id
}
