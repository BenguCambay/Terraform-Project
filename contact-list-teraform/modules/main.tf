
resource "aws_security_group" "tf-ec2-sec" {
    name = "tf-ec2-sg-${var.environment}"
    tags = {
    Name = "tf-ec2-sec-${var.environment}"
    }

    ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    security_groups = [aws_security_group.tf-alb-sec.id]
    }

    ingress {
        from_port = 22
        protocol = "tcp"
        to_port = 22
        cidr_blocks = [ "0.0.0.0/0" ]
    }

    ingress {
        from_port = 443
        protocol = "tcp"
        to_port = 443
        security_groups = [aws_security_group.tf-alb-sec.id]
    }

    egress {
        from_port = 0
        protocol = -1
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}


resource "aws_security_group" "tf-rds-sec" {
    name = "tf-rds-sg-${var.environment}"
    tags = {
    Name = "tf-rds-sec-${var.environment}"
    }

    ingress {
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
    security_groups = [aws_security_group.tf-ec2-sec.id]
    }

    egress {
        from_port = 0
        protocol = -1
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}


resource "aws_security_group" "tf-alb-sec" {
    name = "tf-alb-sg-${var.environment}"
    tags = {
    Name = "tf-alb-sec-${var.environment}"
    }

    ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = [ "0.0.0.0/0" ] 
    }

    ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = [ "0.0.0.0/0" ]
    }

    egress {
        from_port = 0
        protocol = -1
        to_port = 0
        cidr_blocks = [ "0.0.0.0/0" ]
    }
}

resource "aws_launch_template" "tf-LT" {
    name                = "tf-LT-${var.environment}"
    image_id            = var.ec2-ami
    instance_type       = var.ec2-type
    key_name            = var.key
    vpc_security_group_ids = [aws_security_group.tf-ec2-sec.id]
    user_data = base64encode(data.template_file.instance-userdata.rendered)
    tag_specifications {
        resource_type = "instance"

        tags = {
            Name = "contact-list-instance-${var.environment}"
            Environment = "Development"
        }
    }
}


resource "aws_lb_target_group" "tf-target" {
    name     = "tf-target-${var.environment}"
    port     = 80
    protocol = "HTTP"
    vpc_id   = data.aws_vpc.default.id

    health_check {
        path                = "/health"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
    }

    tags = {
    Name = "tf-target-${var.environment}"
    }
}


resource "aws_autoscaling_group" "tf-asg" {
    desired_capacity     = 2
    max_size             = 3
    min_size             = 1
    vpc_zone_identifier  = data.aws_subnets.tf-subnets.ids

    launch_template {
        id      = aws_launch_template.tf-LT.id
        version = "$Latest"
    }

    tag {
        key                 = "Name"
        value               = "contact-list-instance-${var.environment}"
        propagate_at_launch = true
    }

    tag {
        key                 = "Name"
        value               = "tf-asg-${var.environment}"
        propagate_at_launch = false
    }

    health_check_type         = "EC2"
    health_check_grace_period = 200
    default_cooldown          = 200

    target_group_arns = [aws_lb_target_group.tf-target.arn]
}


resource "aws_lb" "tf-alb" {
    name               = "tf-alb-${var.environment}"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.tf-alb-sec.id]
    subnets            = data.aws_subnets.tf-subnets.ids
    enable_deletion_protection = false
    tags = {
        Name = "tf-alb-${var.environment}"
    }
}

resource "aws_lb_listener" "http_listener" {
    load_balancer_arn = aws_lb.tf-alb.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.tf-target.arn
    }
}


resource "aws_db_subnet_group" "tf-rds-db-subnet" {
    name       = "tf-rds-db-subnet-${var.environment}"
    subnet_ids = data.aws_subnets.tf-subnets.ids

    tags = {    Name = "tf-rds-db-subnet-${var.environment}"
    }
}

resource "aws_db_instance" "tfrds" {
    allocated_storage    = 20
    engine               = "mysql"
    engine_version       = "8.0"
    instance_class       = "db.t3.micro"
    db_name              = "tfrds${var.environment}"
    username             = "techpro"
    password             = "techpro123"
    db_subnet_group_name = aws_db_subnet_group.tf-rds-db-subnet.name
    vpc_security_group_ids = [aws_security_group.tf-rds-sec.id]
    skip_final_snapshot  = true

    tags = {
        Name = "tfrds-${var.environment}"
    }
}

resource "github_repository_file" "dbendpoint" {
    content    = aws_db_instance.tfrds.address
    file       = "tfrds.endpoint"
    repository = "Terraform-Project"
    overwrite_on_create = true
    branch     = "main"
}


resource "github_repository_file" "dbname" {
    content    = aws_db_instance.tfrds.db_name
    file       = "tfrds.name"
    repository = "Terraform-Project"
    overwrite_on_create = true
    branch     = "main"
}




resource "aws_route53_record" "www" {
    zone_id = data.aws_route53_zone.hosted-zone.id
    name    = "${var.record}.${var.domain_name}"
    type    = "A"

    alias {
    name                   = aws_lb.tf-alb.dns_name
    zone_id                = aws_lb.tf-alb.zone_id
    evaluate_target_health = true
    }
}




