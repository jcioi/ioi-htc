resource "aws_lb" "rproxy-s3" {
  name = "rproxy-s3"
  internal = true

  security_groups = ["sg-07f4a446b97db9116","sg-048ca01ce45ca77cc"]
  subnets = ["${data.aws_subnet_ids.private.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false

  access_logs {
    bucket = "ioi18-logs"
    prefix = "elb"
    enabled = true
  }
}
resource "aws_lb_listener" "rproxy-s3_80" {
  load_balancer_arn = "${aws_lb.rproxy-s3.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.rproxy-s3.arn}"
    type = "forward"
  }
}
resource "aws_lb_listener" "rproxy-s3_443" {
  load_balancer_arn = "${aws_lb.rproxy-s3.arn}"
  port = 443
  protocol = "HTTPS"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/bc883423-7da4-4259-8828-301b2d5a4cc8"
  ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"

  default_action {
    target_group_arn = "${aws_lb_target_group.rproxy-s3.arn}"
    type = "forward"
  }
}
resource "aws_lb_target_group" "rproxy-s3" {
  name = "rproxy-s3"
  port = 80
  protocol = "HTTP"
  vpc_id = "vpc-03eed691a6a5a03b2"
  target_type = "instance"

  deregistration_delay = 60
  slow_start = 0

  health_check {
    path = "/httpd_alived"
    interval = 6
    healthy_threshold = 3
    unhealthy_threshold = 2
    matcher = "200"
  }
}
