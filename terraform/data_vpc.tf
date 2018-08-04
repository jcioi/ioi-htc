variable "vpc_id" {
  type = "string"
  default = "vpc-03eed691a6a5a03b2"
}

data "aws_subnet_ids" "private" {
  vpc_id = "${var.vpc_id}"
  tags {
    Tier = "private"
  }
}

data "aws_subnet_ids" "public" {
  vpc_id = "${var.vpc_id}"
  tags {
    Tier = "public"
  }
}


