variable "aws_region" { default = "us-east-1" }

provider "aws" {
  region = "${var.aws_region}"
}

//terraform {
//  backend "s3" {
//    key    = "terraform.tfstate"
//  }
//}

data "aws_availability_zones" "available" {
  state = "available"
}
