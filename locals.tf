locals {
  common_tags = {
    Managed_by = "Terraform"
    env        = var.env
    Region     = var.region
    Owner      = "greysquare"
  }
}


