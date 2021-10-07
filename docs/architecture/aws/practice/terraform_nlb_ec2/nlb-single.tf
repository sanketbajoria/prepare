/* resource "aws_eip" "nlb_eip_1a" {
  vpc = true
}

resource "aws_eip" "nlb_eip_1b" {
  vpc = true
}

resource "aws_lb" "practice_lb_single" {
  name               = "practice-lb-single"
  internal           = false
  load_balancer_type = "network"

  enable_deletion_protection = true

  enable_cross_zone_load_balancing = false

  subnets = [aws_subnet.public_subnet_1a.id]

}



resource "aws_lb_listener" "practice_lb_single_http_listener" {
  load_balancer_arn = aws_lb.practice_lb_single.arn
  port              = "80"
  protocol          = "TCP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.practice_lb_single_http_tg.arn
  }
}

resource "aws_lb_target_group" "practice_lb_single_http_tg" {
  name     = "practice-lb-single-http-tg"
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


resource "aws_lb_target_group_attachment" "practice_lb_single_http_ta" {
  count            = length(local.ec2_instance_ids)
  target_group_arn = aws_lb_target_group.practice_lb_single_http_tg.arn
  target_id        = local.ec2_instance_ids[count.index]
  port             = 80
}

 */