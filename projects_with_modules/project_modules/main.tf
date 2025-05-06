provider "aws" {
  region = "us-east-1"
}

module "ec2Inst" {
  source         = "./modules/ec2_instance"
  myami          = "ami-0e449927258d45bc4"
  myinstanceType = "t2.micro"
  name           = "moduleInst"
}

module "s3Buck" {
  source = "./modules/s3_bucket"
  bucket = "ashutoshustestbucket331"
  tags = {
    Name        = "bucket hai 1"
    Environment = "Dev"
  }
}