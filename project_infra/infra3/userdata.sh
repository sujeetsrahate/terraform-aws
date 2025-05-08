#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
echo "Hello from VPC-B EC2 instance!" > /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd
