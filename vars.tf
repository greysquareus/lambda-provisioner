###Common values
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "env" {
  type    = string
  default = "dev"
}

###VPC
variable "vpc_name" {
  type = string
}

variable "enable_nat_gateway" {
  type = bool
}

variable "enable_vpn_gateway" {
  type = bool
}

variable "vpc_cidr" {
  type = string
}

###Subnets
variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}


###Ports for sec hroup
variable "ports" {
  default = ["80", "443"]
  type    = set(string)
}


###EC2
variable "detailed_monitoring" {
  default = false
  type    = bool
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}