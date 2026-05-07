module "vote_service_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "user-service"
  description = "Security group for user-service with custom ports open within VPC, and PostgreSQL publicly open"
  vpc_id      = module.vpc.vpc_id
  tags = merge(local.common_tags, {resource = "Security_group"})

  # ingress_cidr_blocks = ["0.0.0.0/0"]
  # ingress_rules       = ["ssh-tcp"]

  ingress_with_cidr_blocks = [

      for port in vat.ports:
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