resource "aws_subnet" "public_subnet-1" {
  vpc_id     = var.vpc_id
  cidr_block = "172.31.8.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet-2" {
  vpc_id     = var.vpc_id
  cidr_block = "172.31.10.0/24"
  availability_zone = "ap-northeast-2b"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "alb-sg" {
  name        = "tf-bighead-alb-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "was-sg" {
  name        = "tf-bighead-was-sg"
  description = "Allow ALB inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "WAS from ALB"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    security_groups = [aws_security_group.alb-sg.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}


resource "aws_lb_target_group" "content-tg" {
  name        = "tf-content-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    path = "/content"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 300
    matcher = "200"  
  }
}

resource "aws_lb_target_group" "user-tg" {
  name        = "tf-user-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    path = "/user"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 300
    matcher = "200"  
  }
}

resource "aws_lb_target_group" "course-tg" {
  name        = "tf-course-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
  health_check {
    path = "/course"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 300
    matcher = "200"  
  }
}

resource "aws_lb" "ALB" {
  name               = "tf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.public_subnet-1.id, aws_subnet.public_subnet-2.id]
}

resource "aws_lb_listener" "was-listener" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.authentication_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "user" {
  listener_arn = aws_lb_listener.was-listener.arn
  priority     = 1

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.user-tg.arn
  }

  condition {
    path_pattern {
      values = ["/user*"]
    }
  }
}
resource "aws_lb_listener_rule" "content" {
  listener_arn = aws_lb_listener.was-listener.arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.content-tg.arn
  }

  condition {
    path_pattern {
      values = ["/content*"]
    }
  }
}
resource "aws_lb_listener_rule" "course" {
  listener_arn = aws_lb_listener.was-listener.arn
  priority     = 3

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.course-tg.arn
  }

  condition {
    path_pattern {
      values = ["/course*"]
    }
  }
}

resource "aws_route53_record" "cname-record" {
  zone_id = var.hosting_zone_id
  name    = "tfapi"
  type    = "CNAME"
  ttl     = 300
  records        = ["${aws_lb.ALB.dns_name}"]
}

output "alb-arn" {
    value = aws_lb.ALB.arn
}

output "alb-content-tg" {
    value = aws_lb_target_group.content-tg.arn
}

output "alb-user-tg" {
    value = aws_lb_target_group.user-tg.arn
}

output "alb-course-tg" {
    value = aws_lb_target_group.course-tg.arn
}

output "alb-listener" {
    value = aws_lb_listener.was-listener
}
output "bighead-public_subnet-1" {
  value = aws_subnet.public_subnet-1
}
output "bighead-public_subnet-2" {
  value = aws_subnet.public_subnet-2
}

output "bighead-bighead-alb-sg" {
  value = aws_security_group.alb-sg.id
}

output "bighead-bighead-was-sg" {
  value = aws_security_group.was-sg.id
}