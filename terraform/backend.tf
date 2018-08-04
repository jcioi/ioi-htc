terraform {
  backend "s3" {
    region = "ap-northeast-1"
    bucket = "ioi18-infra"
    key    = "terraform/tfstate"
    dynamodb_table = "ioi18-infra-terraform-lock"
  }
}

provider "aws" {
  region = "ap-northeast-1"
  allowed_account_ids = ["550372229658"]
}
