resource "aws_lb" "hako-ioi-console" {
  name = "hako-ioi-console"
  internal = true

  security_groups = ["sg-0cd32a6bd67af4855"]
  subnets = ["${data.aws_subnet_ids.private.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false

  access_logs {
    bucket = "ioi18-logs"
    prefix = "elb"
    enabled = true
  }
}
resource "aws_lb_listener" "hako-ioi-console_443" {
  load_balancer_arn = "${aws_lb.hako-ioi-console.arn}"
  port = 443
  protocol = "HTTPS"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/d849fcde-6e59-4962-b1a2-768af878591a"
  ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    target_group_arn = "${aws_lb_target_group.hako-ioi-console.arn}"
    type = "forward"
  }
}
resource "aws_lb_listener" "hako-ioi-console_80" {
  load_balancer_arn = "${aws_lb.hako-ioi-console.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.hako-ioi-console.arn}"
    type = "forward"
  }
}
resource "aws_lb_target_group" "hako-ioi-console" {
  name = "hako-ioi-console"
  port = 80
  protocol = "HTTP"
  vpc_id = "vpc-03eed691a6a5a03b2"
  target_type = "ip"

  deregistration_delay = 30
  slow_start = 0

  health_check {
    path = "/site/sha"
    interval = 30
    healthy_threshold = 5
    unhealthy_threshold = 2
    matcher = "200"
  }
}
