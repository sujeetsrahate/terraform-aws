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

terraform {
  backend "s3" {
    bucket = "ashutoshustestbucket331"
    key    = "terraform/state.tfstate" #The location for storing the tfstate file in remote 
    region = "us-east-1"
  }

}
module "ec2Inst" {
  source        = "ashutoshsanghi3/ec2-instance/aws"
  version       = "1.0.0"
  ami_id        = "ami-0e449927258d45bc4"
  instance_type = "t2.micro"
  name          = "moduleInstS3Backend"
}