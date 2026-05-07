variable "region" {
  type = string
  default = "us-east-1"
}

variable "env" {
  type = string
  default = "dev"
}

variable "private_subnets" {
  type = list(string)
  default = [ "value" ]
}

variable "public_subnets" {
  type = list(string)
  default = [ "value" ]
}

variable "common_tags" {
  type = map(string)
}

variable "ports" {
  type = set(string)
}