
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket = "workspacebucket-2023"
    key    = "Dev/terraform.tfstate"
    region = "eu-west-1"
  }

  required_version = ">=1.2.0"
}


provider "aws" {
  region = "eu-west-1"
}