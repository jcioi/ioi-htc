resource "aws_lb" "hako-translation-prd" {
  name = "hako-translation-prd"
  internal = true

  security_groups = ["sg-0d628db6dcf52657f"]
  subnets = ["${data.aws_subnet_ids.private.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false

  access_logs {
    bucket = "ioi18-logs"
    prefix = "elb"
    enabled = true
  }
}
resource "aws_lb_listener" "hako-translation-prd_443" {
  load_balancer_arn = "${aws_lb.hako-translation-prd.arn}"
  port = 443
  protocol = "HTTPS"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/0b30594a-ef9d-4268-9d7e-479d28308b66"
  ssl_policy = "ELBSecurityPolicy-2016-08"

  default_action {
    target_group_arn = "${aws_lb_target_group.hako-translation-prd.arn}"
    type = "forward"
  }
}
resource "aws_lb_listener" "hako-translation-prd_80" {
  load_balancer_arn = "${aws_lb.hako-translation-prd.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.hako-translation-prd.arn}"
    type = "forward"
  }
}
resource "aws_lb_target_group" "hako-translation-prd" {
  name = "hako-translation-prd"
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
