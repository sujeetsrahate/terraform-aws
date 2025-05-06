provider "aws" {
  region = "us-east-1"
}

module "ec2Inst" {
  source        = "terraform-aws-modules/ec2-instance/aws"
  name          = "moduleInst3"
  ami           = "ami-0e449927258d45bc4"
  instance_type = "t2.micro"
} 