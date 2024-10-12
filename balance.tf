# balance.tf

resource "aws_security_group" "alb_sg" {
  name        = "allow_http_alb"
  description = "Allow HTTP inbound traffic for ALB"
  vpc_id      = aws_vpc.vpc_cloud_2.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_alb"
  }
}

resource "aws_security_group_rule" "allow_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.my_security_group.id
}

resource "aws_lb" "web_alb" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "Web ALB"
  }
}

resource "aws_lb_target_group" "web_tg" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_cloud_2.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 30
    timeout             = 5
    matcher             = "200-299"
  }

  tags = {
    Name = "WebTargetGroup"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "ec2_1" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.public_ec2_1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "ec2_2" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.public_ec2_2.id
  port             = 80
}

output "alb_dns_name" {
  value = aws_lb.web_alb.dns_name
}
