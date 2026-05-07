terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_subnet" "main" {
  vpc_id     = module.vpc.vpc_id
  cidr_block = "10.0.1.0/24"

  tags = merge(local.common_tags, { resource = "Subnet" })
}

module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "user-service"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = module.vpc.vpc_id
  tags        = merge(local.common_tags, { resource = "Security_group" })

  # ingress_cidr_blocks = ["0.0.0.0/0"]
  # ingress_rules       = ["ssh-tcp"]

  ingress_with_cidr_blocks = [

    for port in var.ports :
    {
      from_port   = port
      to_port     = port
      protocol    = "tcp"
      description = "User-service ports"
      cidr_blocks = join(",", var.private_subnets)
    }
  ]

  egress_rules = ["all-all"]
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  instance_type               = var.instance_type
  monitoring                  = var.detailed_monitoring
  vpc_security_group_ids      = [module.vote_service_sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  key_name                    = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true

  tags = merge(local.common_tags, { resource = "ec2_instance" })
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = merge(local.common_tags, { resource = "vpc" })
}
