resource "aws_lb" "hako-awstools" {
  name = "hako-awstools"
  internal = false

  security_groups = ["sg-0e0b275eb52cde309"]
  subnets = ["${data.aws_subnet_ids.public.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false
}
resource "aws_lb_listener" "hako-awstools_80" {
  load_balancer_arn = "${aws_lb.hako-awstools.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.hako-awstools.arn}"
    type = "forward"
  }
}
resource "aws_lb_listener" "hako-awstools_443" {
  load_balancer_arn = "${aws_lb.hako-awstools.arn}"
  port = 443
  protocol = "HTTPS"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/bb993e86-1acc-4182-9f0d-0d9a371ecd67"
  ssl_policy = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = "${aws_lb_target_group.hako-awstools.arn}"
    type = "forward"
  }
}
resource "aws_lb_target_group" "hako-awstools" {
  name = "hako-awstools"
  port = 80
  protocol = "HTTP"
  vpc_id = "vpc-03eed691a6a5a03b2"
  target_type = "ip"

  deregistration_delay = 300
  slow_start = 0

  health_check {
    path = "/site/sha"
    interval = 30
    healthy_threshold = 5
    unhealthy_threshold = 2
    matcher = "200"
  }
}
