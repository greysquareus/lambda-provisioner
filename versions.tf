terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

data "http" "myip" {
  url = "https://ifconfig.io"
}

data "aws_availability_zones" "available" {
  state = "available"
}

provider "aws" {
  region = var.region
}