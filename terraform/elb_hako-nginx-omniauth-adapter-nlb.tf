resource "aws_lb" "hako-nginx-omniauth-adapter-nlb" {
  name = "hako-nginx-omniauth-adapter-nlb"
  load_balancer_type = "network"
  internal = true

  security_groups = []
  subnets = ["${data.aws_subnet_ids.private.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false
}
resource "aws_lb_listener" "hako-nginx-omniauth-adapter-nlb_80" {
  load_balancer_arn = "${aws_lb.hako-nginx-omniauth-adapter-nlb.arn}"
  port = 80
  protocol = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.hako-nginx-omniauth-adapter-nlb.arn}"
    type = "forward"
  }
}
resource "aws_lb_target_group" "hako-nginx-omniauth-adapter-nlb" {
  name = "hako-nginx-omniauth-adapter-nlb"
  port = 80
  protocol = "TCP"
  vpc_id = "vpc-03eed691a6a5a03b2"
  target_type = "ip"

  deregistration_delay = 30

  health_check {
    protocol = "TCP"
    interval = 30
    healthy_threshold = 3
    unhealthy_threshold = 3
  }
}
