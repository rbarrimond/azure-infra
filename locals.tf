
locals {
  env     = "prod"
  project = "core"
  region  = "eastus"
  suffix  = "${local.project}-${local.env}"
  default_tags = {
    Project     = local.project
    Environment = local.env
    Owner       = "Robert Barrimond"
    ManagedBy   = "Terraform"
  }
}
