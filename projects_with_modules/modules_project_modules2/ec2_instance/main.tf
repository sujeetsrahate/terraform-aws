resource "aws_instance" "sampleIns" {
    ami = var.myami
    instance_type=var.myinstanceType
    tags = {
        Name = var.name
    }
}