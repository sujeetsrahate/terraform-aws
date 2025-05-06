terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "ec2Inst" {
  source        = "github.com/ashutoshsanghi3/terraform-aws-ec2-instance//?ref=v1.0.0"
  ami_id        = "ami-0e449927258d45bc4"
  instance_type = "t2.micro"
  name          = "moduleInstGithub"
}