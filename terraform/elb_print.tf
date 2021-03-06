resource "aws_lb" "print" {
  name = "print"
  internal = true

  security_groups = ["sg-04b24d2dc3e77decf","sg-07f4a446b97db9116"]
  subnets = ["${data.aws_subnet_ids.private.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false

  access_logs {
    bucket = "ioi18-logs"
    prefix = "elb"
    enabled = true
  }
}
resource "aws_lb_listener" "print_443" {
  load_balancer_arn = "${aws_lb.print.arn}"
  port = 443
  protocol = "HTTPS"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/f1255901-983f-4de5-8346-70c74df4477d"
  ssl_policy = "ELBSecurityPolicy-FS-2018-06"

  default_action {
    target_group_arn = "${aws_lb_target_group.print.arn}"
    type = "forward"
  }
}
resource "aws_lb_target_group" "print" {
  name = "print"
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
