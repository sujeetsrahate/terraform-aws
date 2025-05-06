provider "aws" {
  region = var.my-region

}




resource "aws_instance" "web" {
  ami           = var.my-ami-id
  instance_type = var.my-instance-type
  tags = {
    Name = "tf_instance-4"
  }
}


resource "aws_s3_bucket" "example" {
  bucket = "ashutoshustestbucket"

  tags = {
    Name        = "bucket hai"
    Environment = "Dev"
  }
}

