variable "aws_region" { default = "us-east-1" }

provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket = "sandcr01-sli3e9fvjpw4ap9rj2w5"
    key    = "terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = ""
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
