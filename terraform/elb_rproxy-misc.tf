resource "aws_lb" "rproxy-misc" {
  name = "rproxy-misc"
  internal = false

  security_groups = ["sg-07f4a446b97db9116","sg-031f44989a0737c58"]
  subnets = ["${data.aws_subnet_ids.public.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false

  access_logs {
    bucket = "ioi18-logs"
    prefix = "elb"
    enabled = true
  }
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
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/141f6aa1-dc3c-44b4-8d13-59299f8a18e2"
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
resource "aws_lb_listener_certificate" "rproxy-misc_translation" {
  listener_arn = "${aws_lb_listener.rproxy-misc_443.arn}"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/0b30594a-ef9d-4268-9d7e-479d28308b66"
}
resource "aws_lb_listener_certificate" "rproxy-misc_print" {
  listener_arn = "${aws_lb_listener.rproxy-misc_443.arn}"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/6d889bfa-67e9-43e5-8d93-adb39ec31573"
}
resource "aws_lb_listener_certificate" "rproxy-misc_boot" {
  listener_arn = "${aws_lb_listener.rproxy-misc_443.arn}"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/7f0f4800-1f8b-4248-abfe-338b68829b62"
}
resource "aws_lb_listener_certificate" "rproxy-misc_console" {
  listener_arn = "${aws_lb_listener.rproxy-misc_443.arn}"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/d849fcde-6e59-4962-b1a2-768af878591a"
}
resource "aws_lb_listener_certificate" "rproxy-misc_prometheus" {
  listener_arn = "${aws_lb_listener.rproxy-misc_443.arn}"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/02b06b2c-2c1e-4623-a6ae-70acc0cc9076"
}
resource "aws_lb_listener_certificate" "rproxy-misc_netbox" {
  listener_arn = "${aws_lb_listener.rproxy-misc_443.arn}"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/1e7e3ef3-6dcc-4a43-9a17-d64c21defda7"
}
resource "aws_lb_listener_certificate" "rproxy-misc_wlc" {
  listener_arn = "${aws_lb_listener.rproxy-misc_443.arn}"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/2929442d-de92-447d-a6a8-d9ed44c9b870"
}
resource "aws_lb_listener_certificate" "rproxy-misc_auth" {
  listener_arn = "${aws_lb_listener.rproxy-misc_443.arn}"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/61e52d9d-c7cf-4f76-8f0f-72f9ccd92564"
}
# SEE ALSO elb_rproxy-misc-internal.tf

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
