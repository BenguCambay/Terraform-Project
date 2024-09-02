
variable "ec2-ami" {
    default = "ami-0cff7528ff583bf9a"
    description = "instance AMI"
}

variable "ec2-type" {
    default = "t2.micro"
    description = "instance type"
}

variable "key" {
    default = "firstkey"
    description = "keyname"
}

variable "token" {
    default = "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"
    description = "token"
}

variable "certifikaArn" {
    default = "arn:aws:acm:us-east-1:058264318400:certificate/02c1dfe6-5911-4006-a3ea-a58fadddd5b3"
    description = "certifikaArn"
}

variable "domain_name" {
    default = "benfarmet.com"
    description = "domain name"
}

variable "environment" {
    default = "modules"
}

variable "record" {
    default = "www"
}


