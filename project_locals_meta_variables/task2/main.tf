#Create custom infra using variables and locals and meta handlers like dynamic,for each
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

locals {
  public_subnets = {
    "1a" = aws_subnet.public_1a.id
    "1b" = aws_subnet.public_1b.id
  }
  private_subnets = {
    "1a" = aws_subnet.private_1a.id
    "1b" = aws_subnet.private_1b.id
  }
}

resource "aws_vpc" "UST-A-VPC" {
  cidr_block = "192.168.0.0/24"
  tags = { Name = "UST-A-VPC-tag" }
}

resource "aws_internet_gateway" "UST-IGW" {
  vpc_id = aws_vpc.UST-A-VPC.id
  tags = { Name = "UST-IGW-tag" }
}

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.UST-A-VPC.id
  cidr_block              = "192.168.0.0/26"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { Name = "Public-Subnet-1a" }
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.UST-A-VPC.id
  cidr_block        = "192.168.0.64/26"
  availability_zone = "us-east-1a"
  tags = { Name = "Private-Subnet-1a" }
}

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.UST-A-VPC.id
  cidr_block              = "192.168.0.128/26"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { Name = "Public-Subnet-1b" }
}

resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.UST-A-VPC.id
  cidr_block        = "192.168.0.192/26"
  availability_zone = "us-east-1b"
  tags = { Name = "Private-Subnet-1b" }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.UST-A-VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.UST-IGW.id
  }
  tags = { Name = "Public-RT" }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.UST-A-VPC.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = { Name = "Private-RT" }
}

resource "aws_route_table_association" "public" {
  for_each       = local.public_subnets
  subnet_id      = each.value
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private" {
  for_each       = local.private_subnets
  subnet_id      = each.value
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_1a.id
  tags = { Name = "NAT-GW" }
}

resource "aws_security_group" "UST-A-SG" {
  name        = "UST-A-SG"
  description = "Allow SSH and HTTP"
  vpc_id      = aws_vpc.UST-A-VPC.id

  dynamic "ingress" {
    for_each = [22, 80]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_network_acl" "UST-A-VPC-NACL" {
  vpc_id = aws_vpc.UST-A-VPC.id

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_network_acl_association" "public" {
  for_each        = local.public_subnets
  subnet_id       = each.value
  network_acl_id  = aws_network_acl.UST-A-VPC-NACL.id
}

resource "aws_network_acl_association" "private" {
  for_each        = local.private_subnets
  subnet_id       = each.value
  network_acl_id  = aws_network_acl.UST-A-VPC-NACL.id
}

resource "aws_instance" "public" {
  count                       = 2
  ami                         = "ami-0f88e80871fd81e91"
  instance_type               = "t2.micro"
  subnet_id                   = [aws_subnet.public_1a.id, aws_subnet.public_1b.id][count.index]
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.UST-A-SG.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Public EC2 in ${["1a", "1b"][count.index]}</h1>" > /var/www/html/index.html
  EOF

  tags = { Name = "Public-EC2-${["1a", "1b"][count.index]}" }
}

resource "aws_instance" "private" {
  count                  = 2
  ami                    = "ami-0f88e80871fd81e91"
  instance_type          = "t2.micro"
  subnet_id              = [aws_subnet.private_1a.id, aws_subnet.private_1b.id][count.index]
  vpc_security_group_ids = [aws_security_group.UST-A-SG.id]
  tags                   = { Name = "Private-EC2-${["1a", "1b"][count.index]}" }
}

output "public_ec2_ips" {
  value = [for instance in aws_instance.public : instance.public_ip]
}

output "private_ec2_ips" {
  value = [for instance in aws_instance.private : instance.private_ip]
}
