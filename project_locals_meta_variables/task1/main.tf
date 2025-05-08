#Practice using `string`, `number`, `list`, `set`, and `map` variables in Terraform. 
#Convert them to `locals` with simple examples. 
#Show when to use locals, use `for_each` with a list, and demonstrate `count` with a small example. 

provider "aws" {
  region = "us-east-1"
}

#Using locals to define variables
locals {
  instance_type       = var.instance_type
  instance_count      = var.instance_count
  azs                 = var.availability_zones
  tags                = tolist(var.unique_tags)  # sets must be converted to list for indexing
  named_instances     = var.instance_names
}


# EC2 instances using for_each (named instances)
resource "aws_instance" "web" {
  for_each = local.named_instances

  ami           = "ami-0f88e80871fd81e91"  
  instance_type = local.instance_type

  tags = {
    Name = each.value
    Role = "for_each"
  }
}

# EC2 instances using count (identical instances)
resource "aws_instance" "multi" {
  count         = local.instance_count
  ami           = "ami-0f88e80871fd81e91"
  instance_type = local.instance_type

  tags = {
    Name = "Instance-${count.index+1}"
    Role = "count"
  }
}
