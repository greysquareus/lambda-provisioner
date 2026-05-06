locals {
  ports = toset(["22", "80", "443", "8080", "9090", "9091", "8081"])

  private_subnets = ["10.0.10.0/24"]
  public_subnets  = ["10.0.100.0/24"]

  common_tags = {
    Managed_by = "Terraform"
    env = var.env
    Region = var.region
    Owner = "greysquare"
  }
}


