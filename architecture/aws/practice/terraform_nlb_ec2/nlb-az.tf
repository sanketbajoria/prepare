resource "aws_eip" "nlb_eip_1a" {
  vpc = true
}

resource "aws_eip" "nlb_eip_1b" {
  vpc = true
}

resource "aws_lb" "practice_lb" {
  name               = "practice-lb"
  internal           = false
  load_balancer_type = "network"

  enable_deletion_protection = true

  enable_cross_zone_load_balancing = true

  subnet_mapping {
    subnet_id     = aws_subnet.public_subnet_1a.id
    allocation_id = aws_eip.nlb_eip_1a.id
  }

  subnet_mapping {
    subnet_id     =aws_subnet.public_subnet_1b.id
    allocation_id = aws_eip.nlb_eip_1b.id
  }

}



resource "aws_lb_listener" "practice_lb_http_listener" {
  load_balancer_arn = aws_lb.practice_lb.arn
  port              = "80"
  protocol          = "TCP"
  
  default_action {
    type             = "forward"
    target_group_arn = var.backup?aws_lb_target_group.practice_lb_http_tg_back.arn:aws_lb_target_group.practice_lb_http_tg.arn
  }
}

resource "aws_lb_target_group" "practice_lb_http_tg" {
  name     = "practice-lb-http-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.practice_vpc.id
  health_check {
    interval            = 10
    port                = 80
    protocol            = "TCP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


resource "aws_lb_target_group_attachment" "practice_lb_http_ta" {
  count            = length(local.ec2_instance_ids)
  target_group_arn = aws_lb_target_group.practice_lb_http_tg.arn
  target_id        = local.ec2_instance_ids[count.index]
  port             = 80
}

resource "aws_lb_target_group" "practice_lb_http_tg_back" {
  name     = "practice-lb-http-tg-back"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.practice_vpc.id
  health_check {
    interval            = 10
    port                = 80
    protocol            = "TCP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}


resource "aws_lb_target_group_attachment" "practice_lb_http_ta_back" {
  count            = length(local.ec2_instance_back_ids)
  target_group_arn = aws_lb_target_group.practice_lb_http_tg_back.arn
  target_id        = local.ec2_instance_back_ids[count.index]
  port             = 80
}

