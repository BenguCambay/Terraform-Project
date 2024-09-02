output "ec2-sec-gr-id" {
    value = aws_security_group.tf-ec2-sec.id
}

output "hosted_zone" {
    value = data.aws_route53_zone.hosted-zone.name
}

output "domain-ame" {
    value = var.domain_name
}

output "RDS_Name" {
    value = aws_db_instance.tfrds.db_name
}