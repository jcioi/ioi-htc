resource "aws_lb" "cms-ranking-dev" {
  name = "cms-ranking-dev"
  internal = false

  security_groups = ["sg-07f4a446b97db9116","sg-07974564bf9b9e29e"]
  subnets = ["${data.aws_subnet_ids.public.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false
}
resource "aws_lb_listener" "cms-ranking-dev_80" {
  load_balancer_arn = "${aws_lb.cms-ranking-dev.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.cms-ranking-dev.arn}"
    type = "forward"
  }
}
resource "aws_lb_listener" "cms-ranking-dev_443" {
  load_balancer_arn = "${aws_lb.cms-ranking-dev.arn}"
  port = 443
  protocol = "HTTPS"
  certificate_arn = "arn:aws:acm:ap-northeast-1:550372229658:certificate/475adc22-8669-419b-aa5d-36ba004df5a0"
  ssl_policy = "ELBSecurityPolicy-FS-2018-06"

  default_action {
    target_group_arn = "${aws_lb_target_group.cms-ranking-dev.arn}"
    type = "forward"
  }
}
resource "aws_lb_target_group" "cms-ranking-dev" {
  name = "cms-ranking-dev"
  port = 80
  protocol = "HTTP"
  vpc_id = "vpc-03eed691a6a5a03b2"
  target_type = "instance"

  deregistration_delay = 300
  slow_start = 0

  health_check {
    path = "/httpd_alived"
    interval = 6
    healthy_threshold = 3
    unhealthy_threshold = 2
    matcher = "200"
  }
}
