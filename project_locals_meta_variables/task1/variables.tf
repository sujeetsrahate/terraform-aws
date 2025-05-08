variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "unique_tags" {
  type    = set(string)
  default = ["web", "dev"]
}

variable "instance_names" {
  type = map(string)
  default = {
    "web1" = "Web Server 1"
    "web2" = "Web Server 2"
  }
}
