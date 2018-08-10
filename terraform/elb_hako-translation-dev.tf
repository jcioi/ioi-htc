resource "aws_lb" "hako-translation-dev" {
  name = "hako-translation-dev"
  internal = false

  security_groups = ["sg-035c00f22c7fe5429"]
  subnets = ["${data.aws_subnet_ids.public.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false

  access_logs {
    bucket = "ioi18-logs"
    prefix = "elb"
    enabled = true
  }
}
resource "aws_lb_listener" "hako-translation-dev_443" {
  load_balancer_arn = "${aws_lb.hako-translation-dev.arn}"
  port = 443
  protocol = "HTTPS"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/f322e479-c94f-4683-b20f-17a2e652fe64"
  ssl_policy = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = "${aws_lb_target_group.hako-translation-dev.arn}"
    type = "forward"
  }
}
resource "aws_lb_listener" "hako-translation-dev_80" {
  load_balancer_arn = "${aws_lb.hako-translation-dev.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.hako-translation-dev.arn}"
    type = "forward"
  }
}
resource "aws_lb_target_group" "hako-translation-dev" {
  name = "hako-translation-dev"
  port = 80
  protocol = "HTTP"
  vpc_id = "vpc-03eed691a6a5a03b2"
  target_type = "ip"

  deregistration_delay = 30
  slow_start = 0

  health_check {
    path = "/healthcheck"
    interval = 6
    healthy_threshold = 3
    unhealthy_threshold = 2
    matcher = "200"
  }
}
