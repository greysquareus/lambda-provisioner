##Common-vars
region = "us-east-1"
env = "dev"

###Sec-group
ports = ["22", "80", "443", "8080", "9090", "9091", "8081"]

private_subnets = ["10.0.10.0/24"]
public_subnets  = ["10.0.100.0/24"]

###VPC
vpc_name = "my-vpc"
vpc_cidr="10.0.0.0/16"
enable_nat_gateway = true
enable_vpn_gateway = true

###EC2
instance_type = "t3.micro"
detailed_monitoring = false