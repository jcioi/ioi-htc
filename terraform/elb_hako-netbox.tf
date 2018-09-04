resource "aws_lb" "hako-netbox" {
  name = "hako-netbox"
  internal = true

  security_groups = ["sg-0d6c8d7523b36c389"]
  subnets = ["${data.aws_subnet_ids.private.ids}"]

  idle_timeout = 60
  enable_deletion_protection = false
}
resource "aws_lb_listener" "hako-netbox_80" {
  load_balancer_arn = "${aws_lb.hako-netbox.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.hako-netbox.arn}"
    type = "forward"
  }
}
resource "aws_lb_target_group" "hako-netbox" {
  name = "hako-netbox"
  port = 80
  protocol = "HTTP"
  vpc_id = "vpc-03eed691a6a5a03b2"
  target_type = "ip"

  deregistration_delay = 300
  slow_start = 0

  health_check {
    path = "/"
    interval = 30
    healthy_threshold = 5
    unhealthy_threshold = 2
    matcher = "301"
  }
}
