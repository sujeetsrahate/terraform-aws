terraform {
 required_providers {
  aws = {
   source = "hashicorp/aws"
   version = "~> 5.0"
  }
 }

}
provider "aws" {
  region = "us-east-1"
}
resource "aws_instance" "example" {
 ami = "ami-0953476d60561c955" # Amazon Linux 2 AMI in us-east-1
 instance_type = "t2.micro"
 tags = {
  Name = "EBS-Demo-Instance"
 }
 root_block_device {
  volume_size = 8
 }
}
resource "aws_ebs_volume" "example" {
 availability_zone = aws_instance.example.availability_zone
 size = 10
 type = "gp3"
 tags = {
  Name = "Demo-Volume"
 }
}
resource "aws_volume_attachment" "example" {
 device_name = "/dev/sdf"
 volume_id = aws_ebs_volume.example.id
 instance_id = aws_instance.example.id
 force_detach = true
}