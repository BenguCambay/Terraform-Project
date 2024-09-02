
variable "ec2-ami" {
    default = "ami-0cff7528ff583bf9a"
    description = "instance AMI"
}

variable "ec2-type" {
    default = "t2.micro"
    description = "instance type"
}

variable "key" {
    default = "mynewPair"
    description = "keyname"
}

variable "token" {
    default = "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"
    description = "token"
}

variable "certifikaArn" {
    default = "arn:aws:acm:us-east-1:992382643040:certificate/ec21b6b8-d84b-4bee-b21b-53bf5cb3d495"
    description = "certifikaArn"
}

variable "domain_name" {
    default = "datacheck.space"
    description = "domain name"
}

variable "environment" {
    default = "modules"
}

variable "record" {
    default = "www"
}


