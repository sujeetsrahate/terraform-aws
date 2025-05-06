resource "aws_s3_bucket" "moduleBuck" {
  bucket = var.bucket
  tags = var.tags
}