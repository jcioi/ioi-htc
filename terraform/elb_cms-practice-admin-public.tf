resource "aws_lb" "cms-practice-admin-public" {
  name = "cms-practice-admin-public"
  internal = false

  security_groups = ["sg-07f4a446b97db9116","sg-0bc7139e4fe676f96"]
  subnets = ["${data.aws_subnet_ids.public.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false

  access_logs {
    bucket = "ioi18-logs"
    prefix = "elb"
    enabled = true
  }
}
resource "aws_lb_listener" "cms-practice-admin-public_80" {
  load_balancer_arn = "${aws_lb.cms-practice-admin-public.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.cms-practice-admin-public.arn}"
    type = "forward"
  }
}
resource "aws_lb_listener" "cms-practice-admin-public_443" {
  load_balancer_arn = "${aws_lb.cms-practice-admin-public.arn}"
  port = 443
  protocol = "HTTPS"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/6615d5fe-de1b-4603-8b19-ec57f4002822"
  ssl_policy = "ELBSecurityPolicy-FS-2018-06"

  default_action {
    target_group_arn = "${aws_lb_target_group.cms-practice-admin-public.arn}"
    type = "forward"
  }
}
resource "aws_lb_target_group" "cms-practice-admin-public" {
  name = "cms-practice-admin"
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
