provider "aws" {
  region = "us-east-1"
}

module "ec2Inst" {
  source         = "../modules_project_modules2/ec2_instance"
  myami          = "ami-0e449927258d45bc4"
  myinstanceType = "t2.micro"
  name           = "moduleInst2"
} 