
locals {
  env     = "prod"
  project = "core"
  region  = "eastus2"
  suffix  = "${local.project}-${local.env}-rrb001"
  default_tags = {
    Project     = local.project
    Environment = local.env
    Owner       = "Robert Barrimond"
    ManagedBy   = "Terraform"
  }
}
