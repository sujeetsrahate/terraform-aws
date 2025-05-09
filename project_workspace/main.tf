provider "aws" {
    region = "us-east-1"
}

#Scenario 1:Real-Time Scenario: Deploying Infrastructure in Dev, Staging

variable "instance_type" {
  default="t3.micro"
  type = string 
}

data "aws_ssm_parameter" "latest_amazon_linux2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

resource "aws_instance" "my_instance" {
  ami           = data.aws_ssm_parameter.latest_amazon_linux2.value
  instance_type = var.instance_type
  tags = {
    Name = terraform.workspace
  }
}

# Scenario 2:Provisioning S3 Buckets for Dev, Staging
resource "aws_s3_bucket" "logs" {
  bucket = "logs-${terraform.workspace}-bucket-ashutosh124"
}


#Scenario 3: VPC
resource "aws_vpc" "sample_vpc" {
  cidr_block="10.${terraform.workspace == "dev" ? 0 : terraform.workspace == "stage" ? 1 : 2}.0.0/16"
  tags={
    Name = "${terraform.workspace}-vpc"
  }
}

#Scenario 4: RDS
resource "aws_db_instance" "db" {
  identifier = "app-db-${terraform.workspace}"
  instance_class = terraform.workspace == "stage" ? "db.t3.large" : "db.t3.micro"
  allocated_storage = terraform.workspace == "stage" ? 100 : 20
  engine = "mysql"
  username = "admin"
  password = "adminadm"
  skip_final_snapshot = true 
}