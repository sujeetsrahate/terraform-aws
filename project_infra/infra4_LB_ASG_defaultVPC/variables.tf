variable "ami_id" {
 description = "AMI ID for EC2 instances"
 type = string
 default = "ami-0f88e80871fd81e91" # Change to a valid AMI in your region
}

variable "instance_type" {
 description = "EC2 instance type"
 type = string
 default = "t2.micro"
}
