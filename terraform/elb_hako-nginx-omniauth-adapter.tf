resource "aws_lb" "hako-nginx-omniauth-adapter" {
  name = "hako-nginx-omniauth-adapter"
  internal = true

  security_groups = ["sg-06f0c7cda02530a27"]
  subnets = ["${data.aws_subnet_ids.private.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false
}
resource "aws_lb_listener" "hako-nginx-omniauth-adapter_443" {
  load_balancer_arn = "${aws_lb.hako-nginx-omniauth-adapter.arn}"
  port = 443
  protocol = "HTTPS"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/61e52d9d-c7cf-4f76-8f0f-72f9ccd92564"
  ssl_policy = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = "${aws_lb_target_group.hako-nginx-omniauth-adapter.arn}"
    type = "forward"
  }
}
resource "aws_lb_listener" "hako-nginx-omniauth-adapter_80" {
  load_balancer_arn = "${aws_lb.hako-nginx-omniauth-adapter.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.hako-nginx-omniauth-adapter.arn}"
    type = "forward"
  }
}
resource "aws_lb_target_group" "hako-nginx-omniauth-adapter" {
  name = "hako-nginx-omniauth-adapter"
  port = 80
  protocol = "HTTP"
  vpc_id = "vpc-03eed691a6a5a03b2"
  target_type = "ip"

  deregistration_delay = 300
  slow_start = 0

  health_check {
    path = "/site/sha"
    interval = 6
    healthy_threshold = 3
    unhealthy_threshold = 2
    matcher = "200"
  }
}
