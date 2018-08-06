resource "aws_lb" "hako-translation-practice" {
  name = "hako-translation-practice"
  internal = false

  security_groups = ["sg-0d64b25feaaaa7225"]
  subnets = ["${data.aws_subnet_ids.public.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false
}
resource "aws_lb_listener" "hako-translation-practice_443" {
  load_balancer_arn = "${aws_lb.hako-translation-practice.arn}"
  port = 443
  protocol = "HTTPS"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/bbea314d-ea38-412e-8909-c65c89981a71"
  ssl_policy = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = "${aws_lb_target_group.hako-translation-practice.arn}"
    type = "forward"
  }
}
resource "aws_lb_listener" "hako-translation-practice_80" {
  load_balancer_arn = "${aws_lb.hako-translation-practice.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.hako-translation-practice.arn}"
    type = "forward"
  }
}
resource "aws_lb_target_group" "hako-translation-practice" {
  name = "hako-translation-practice"
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
