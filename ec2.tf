module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  instance_type = "t3.micro"
  monitoring    = false
  vpc_security_group_ids = [module.vote_service_sg.security_group_id]
  subnet_id     = module.vpc.public_subnets[0]
  key_name = aws_key_pair.key_pair.key_name
  associate_public_ip_address = true

  tags = merge(local.common_tags, {resource = "ec2_instance"})
}