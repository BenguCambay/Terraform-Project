data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "tf-subnets" {
    filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
    }

    filter {
    name   = "tag:Name"
    values = ["tf-subnet1","tf-subnet2"]
    }
}


data "template_file" "instance-userdata" {
    template = file("${path.module}/userdata.sh")
}

data "aws_route53_zone" "hosted-zone" {
    name         = var.domain_name
    private_zone = false
}