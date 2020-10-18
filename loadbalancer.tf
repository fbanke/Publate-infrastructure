resource "aws_alb" "main" {
  security_groups = [aws_security_group.ecs_sg.id]
  subnets = [
    aws_subnet.pub_subnet[0].id,
    aws_subnet.pub_subnet[1].id,
    aws_subnet.pub_subnet[2].id
  ]
  name = "alb-Publate"
}

resource "aws_alb_target_group" "main" {
  name = "tgPublate"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    timeout             = "3"
    path                = "/health"
    unhealthy_threshold = "2"
  }

  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_alb.main.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.main.id
    type             = "forward"
  }
}