resource "aws_lb" "cms-prd" {
  name = "cms-prd"
  internal = true

  security_groups = ["sg-0bc36f7e20387764e","sg-07f4a446b97db9116"]
  subnets = ["${data.aws_subnet_ids.private.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false

  access_logs {
    bucket = "ioi18-logs"
    prefix = "elb"
    enabled = true
  }
}
resource "aws_lb_listener" "cms-prd_80" {
  load_balancer_arn = "${aws_lb.cms-prd.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.cms-prd.arn}"
    type = "forward"
  }
}
resource "aws_lb_listener" "cms-prd_443" {
  load_balancer_arn = "${aws_lb.cms-prd.arn}"
  port = 443
  protocol = "HTTPS"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/9091afd1-90cc-4ec6-b701-7bb8ebe9211d"
  ssl_policy = "ELBSecurityPolicy-FS-2018-06"

  default_action {
    target_group_arn = "${aws_lb_target_group.cms-prd.arn}"
    type = "forward"
  }
}
resource "aws_lb_target_group" "cms-prd" {
  name = "cms-prd-contest"
  port = 80
  protocol = "HTTP"
  vpc_id = "vpc-03eed691a6a5a03b2"
  target_type = "instance"

  deregistration_delay = 60
  slow_start = 0

  health_check {
    path = "/healthcheck"
    interval = 6
    healthy_threshold = 3
    unhealthy_threshold = 2
    matcher = "200"
  }
}
