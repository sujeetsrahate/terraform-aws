#Creating custom infrastructure with variables
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# VPC
resource "aws_vpc" "vpc_b" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw_b" {
  vpc_id = aws_vpc.vpc_b.id
  tags = {
    Name = var.igw_name
  }
}

# Public Subnet
resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.vpc_b.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.az
  map_public_ip_on_launch = true
  tags = {
    Name = var.public_subnet_name
  }
}

#Private Subnet
resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.vpc_b.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.az
  tags = {
    Name = var.private_subnet_name
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public_rt_b" {
  vpc_id = aws_vpc.vpc_b.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_b.id
  }
  tags = {
    Name = var.public_rt_name
  }
}

#Route Table for Private Subnet
resource "aws_route_table" "private_rt_b" {
  vpc_id = aws_vpc.vpc_b.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b.id
  }
  tags = {
    Name = var.private_rt_name
  }
}

#Public Subnet Route Table Association
resource "aws_route_table_association" "PublicSubnet-RT-Association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt_b.id
}

#Private Subnet Route Table Association
resource "aws_route_table_association" "PrivateSubnet-RT-Association" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt_b.id
}

#Elastic IP for NAT Gateway
resource "aws_eip" "eip-B-NAT" {
  domain = "vpc"
}

# NAT Gateway
resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.eip-B-NAT.id
  subnet_id     = aws_subnet.public_subnet_b.id
  tags = {
    Name = var.natgw_name
  }
}

# Security Group
resource "aws_security_group" "sg_b" {
  vpc_id = aws_vpc.vpc_b.id
  name   = var.sg_name
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

  tags = {
    Name = var.sg_name
  }
}

#NACL
resource "aws_network_acl" "B-VPC-NACL" {
  vpc_id = aws_vpc.vpc_b.id
  tags = {
    Name = "B-VPC-NACL"
  }

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
resource "aws_network_acl_association" "B-NACL-PublicSubnet" {
  subnet_id      = aws_subnet.public_subnet_b.id
  network_acl_id = aws_network_acl.B-VPC-NACL.id
}

#NACL Association with Private Subnet
resource "aws_network_acl_association" "B-NACL-PrivateSubnet" {
  subnet_id      = aws_subnet.private_subnet_b.id
  network_acl_id = aws_network_acl.B-VPC-NACL.id
}

# EC2 Instance (Public)
resource "aws_instance" "public_instance_b" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet_b.id
  vpc_security_group_ids      = [aws_security_group.sg_b.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/userdata.sh")
  tags = {
    Name = var.public_ec2_name
  }
}

# EC2 Instance (Private)
resource "aws_instance" "private_instance_b" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet_b.id
  vpc_security_group_ids = [aws_security_group.sg_b.id]
  tags = {
    Name = var.private_ec2_name
  }
}