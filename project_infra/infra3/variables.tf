variable "region" {
  description = "AWS region"
  type        = string
}

variable "az" {
  description = "Availability zone"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "vpc_name" {
  description = "Name tag for VPC"
  type        = string
}

variable "igw_name" {
  description = "Name tag for Internet Gateway"
  type        = string
}

variable "public_subnet_name" {
  description = "Name tag for Public Subnet"
  type        = string
}

variable "private_subnet_name" {
  description = "Name tag for Private Subnet"
  type        = string
}
variable "public_rt_name" {
  description = "Name tag for Public Route Table"
  type        = string
}

variable "private_rt_name" {
  description = "Name tag for Private Route Table"
  type        = string
}
variable "sg_name" {
  description = "Name tag for Security Group"
  type        = string
}

variable "public_ec2_name" {
  description = "Name tag for Public EC2 instance"
  type        = string
}

variable "private_ec2_name" {
  description = "Name tag for Private EC2 instance"
  type        = string
}
variable "natgw_name" {
  description = "Name tag for NAT Gateway"
  type        = string
}