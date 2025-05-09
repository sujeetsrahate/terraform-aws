terraform {
  backend "s3" {
    bucket = "bucketfordifferentenvrionment142" 
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}