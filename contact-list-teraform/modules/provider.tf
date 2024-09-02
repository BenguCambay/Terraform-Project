terraform {
    required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.65.0"
    }

    github = {
        source = "integrations/github"
        version = "6.2.3"
    }
    }
}

provider "aws" {
    region = "us-east-1"
}

provider "github" {
    token = var.token
}