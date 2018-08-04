resource "aws_lb" "cms-dev" {
  name = "cms-dev"
  internal = true

  security_groups = ["sg-07f4a446b97db9116","sg-0e821dd1a7655e981"]
  subnets = ["${data.aws_subnet_ids.private.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false
}
resource "aws_lb_listener" "cms-dev_80" {
  load_balancer_arn = "${aws_lb.cms-dev.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.cms-dev.arn}"
    type = "forward"
  }
}
resource "aws_lb_target_group" "cms-dev" {
  name = "cms-contest-dev"
  port = 80
  protocol = "HTTP"
  vpc_id = "vpc-03eed691a6a5a03b2"
  target_type = "instance"

  deregistration_delay = 300
  slow_start = 0

  health_check {
    path = "/httpd_alived"
    interval = 6
    healthy_threshold = 2
    unhealthy_threshold = 3
    matcher = "200"
  }
}
