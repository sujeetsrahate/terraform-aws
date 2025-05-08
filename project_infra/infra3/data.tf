# Get latest Amazon Linux 2 AMI from SSM

#Method 1
# This example uses the AWS provider to fetch the latest Amazon Linux 2 AMI ID
# using the `aws_ami` data source. The AMI is filtered by name and virtualization type.
# The `most_recent` argument ensures that the most recent AMI is selected.
# The `owners` argument specifies the owner of the AMI, which is Amazon in this case.
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]  # Amazon's official AMIs
}

#Method 2
# This example uses the AWS Systems Manager (SSM) Parameter Store to fetch the latest
# Amazon Linux 2 AMI ID. The parameter name is specified, and the `data` block retrieves
# the parameter value. The `version` argument specifies the version of the parameter to retrieve.
# The `with_decryption` argument is set to false, as the parameter is not encrypted.

/*
  data "aws_ssm_parameter" "latest_amazon_linux2" {
    name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
  }
*/
