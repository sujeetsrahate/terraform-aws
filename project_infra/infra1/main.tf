#Create custom AWS infrastructure like VPC,subnets,security groups,route table,IGW,NAT Gateway,instance
#Launch instances in the subnets with security groups and NACLs (Network Access Control Lists)

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#VPC
resource "aws_vpc" "UST-A-VPC" {
  cidr_block = "192.168.0.0/24"
  tags = {
    Name = "UST-A-VPC-tag"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "UST-IGW" {
  vpc_id = aws_vpc.UST-A-VPC.id
  tags = {
    Name = "UST-IGW-tag"
  }
}

#Public Subnet
resource "aws_subnet" "UST-A-PublicSubnet" {
  vpc_id            = aws_vpc.UST-A-VPC.id
  cidr_block        = "192.168.0.0/25"
  availability_zone = "us-east-1a"
  tags = {
    Name = "UST-A-PublicSubnet-tag"
  }
}

#Private Subnet
resource "aws_subnet" "UST-A-PrivateSubnet" {
  vpc_id            = aws_vpc.UST-A-VPC.id
  cidr_block        = "192.168.0.128/25"
  availability_zone = "us-east-1b"
  tags = {
    Name = "UST-A-PrivateSubnet-tag"
  }
}

#Route table for PublicSubnet
resource "aws_route_table" "UST-A-PublicSubnet-RT" {
  vpc_id = aws_vpc.UST-A-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.UST-IGW.id
  }
  tags = {
    Name = "UST-A-PublicSubnet-RT-tag"
  }
}

#Route table for PrivateSubnet
resource "aws_route_table" "UST-A-PrivateSubnet-RT" {
  vpc_id = aws_vpc.UST-A-VPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.UST-A-NAT-GW.id
  }
  tags = {
    Name = "UST-A-PrivateSubnet-RT-tag"
  }
}

#PublicSubnet Route Table Association
resource "aws_route_table_association" "PublicSubnet-RT-Association" {
  subnet_id      = aws_subnet.UST-A-PublicSubnet.id
  route_table_id = aws_route_table.UST-A-PublicSubnet-RT.id
}

#PrivateSubnet Route Table Association
resource "aws_route_table_association" "PrivateSubnet-RT-Association" {
  subnet_id      = aws_subnet.UST-A-PrivateSubnet.id
  route_table_id = aws_route_table.UST-A-PrivateSubnet-RT.id
}

#Elastic IP for NAT Gateway
resource "aws_eip" "eip-NAT" {
  domain = "vpc"
}

#NAT Gateway
resource "aws_nat_gateway" "UST-A-NAT-GW" {
  allocation_id = aws_eip.eip-NAT.id
  subnet_id     = aws_subnet.UST-A-PublicSubnet.id
  tags = {
    Name = "UST-A-NAT-GW-tag"
  }
}

#Security Group
resource "aws_security_group" "UST-A-SG" {
  vpc_id      = aws_vpc.UST-A-VPC.id
  name        = "UST-A-SG"
  description = "Allow SSH and HTTP"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#NACL
resource "aws_network_acl" "A-VPC-NACL" {
  vpc_id = aws_vpc.UST-A-VPC.id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

#NACL Association with Public Subnet
resource "aws_network_acl_association" "A-NACL-PublicSubnet" {
  subnet_id      = aws_subnet.UST-A-PublicSubnet.id
  network_acl_id = aws_network_acl.A-VPC-NACL.id
}

#NACL Association with Private Subnet
resource "aws_network_acl_association" "A-NACL-PrivateSubnet" {
  subnet_id      = aws_subnet.UST-A-PrivateSubnet.id
  network_acl_id = aws_network_acl.A-VPC-NACL.id
}

#EC2 Public Instance
resource "aws_instance" "UST-A-PublicInstance" {
  ami                         = "ami-0f88e80871fd81e91"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.UST-A-PublicSubnet.id
  vpc_security_group_ids      = [aws_security_group.UST-A-SG.id]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<html><body><h1>This is your Public Instance from Custom VPC UST-A-VPC</h1></body></html>" > /var/www/html/index.html
  EOF

  tags = {
    Name = "UST-A-PublicInstance-tag"
  }
}

#EC2 Private Instance
resource "aws_instance" "UST-A-PrivateInstance" {
  ami                    = "ami-0f88e80871fd81e91"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.UST-A-PrivateSubnet.id
  vpc_security_group_ids = [aws_security_group.UST-A-SG.id]

  tags = {
    Name = "UST-A-PrivateInstance-tag"
  }
}
