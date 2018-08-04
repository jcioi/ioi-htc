data "aws_security_groups" "apne1" {
  filter {
    name   = "vpc-id"
    values = ["${var.vpc_id}"]
  }
}
