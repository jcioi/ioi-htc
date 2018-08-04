resource "aws_lb" "rproxy-misc" {
  name = "rproxy-misc"
  internal = false

  security_groups = ["sg-07f4a446b97db9116","sg-031f44989a0737c58"]
  subnets = ["${data.aws_subnet_ids.public.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false
}
resource "aws_lb_listener" "rproxy-misc_80" {
  load_balancer_arn = "${aws_lb.rproxy-misc.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.rproxy-misc.arn}"
    type = "forward"
  }
}
resource "aws_lb_listener" "rproxy-misc_443" {
  load_balancer_arn = "${aws_lb.rproxy-misc.arn}"
  port = 443
  protocol = "HTTPS"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/61e52d9d-c7cf-4f76-8f0f-72f9ccd92564"
  ssl_policy = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"

  default_action {
    target_group_arn = "${aws_lb_target_group.rproxy-misc.arn}"
    type = "forward"
  }
}
resource "aws_lb_listener_certificate" "rproxy-misc_cms-dev" {
  listener_arn = "${aws_lb_listener.rproxy-misc_443.arn}"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/3eb21034-26cc-40eb-a2c5-446d94fb1020"
}

resource "aws_lb_target_group" "rproxy-misc" {
  name = "rproxy-misc"
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
