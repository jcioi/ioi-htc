resource "aws_lb" "hako-netbox" { }
resource "aws_lb_listener" "hako-netbox_80" { }
resource "aws_lb_target_group" "hako-netbox" { }
