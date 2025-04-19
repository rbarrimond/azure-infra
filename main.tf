provider "azurerm" {
  features {}

  # Optionally specify a subscription or tenant if needed
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.3.0"
}

module "core" {
  source = "./modules/core"

  suffix        = local.suffix
  tenant_id     = var.tenant_id
  region        = local.region
  default_tags  = local.default_tags
}
