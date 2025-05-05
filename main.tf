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

resource "random_string" "module_suffix" {
  length  = 4
  upper   = false
  special = false
}

locals {
  env            = var.environment
  core_suffix    = "core-${local.env}-${random_string.module_suffix.result}"
  baldwin_suffix = "baldwin-${local.env}-${random_string.module_suffix.result}"
}

module "core" {
  source    = "./modules/core"
  suffix    = local.core_suffix
  tenant_id = var.tenant_id
  region    = var.region
  default_tags = {
    environment = local.env
    project     = "core"
  }
}

module "baldwin" {
  source                   = "./modules/baldwin"
  suffix                   = local.baldwin_suffix
  location                 = var.region
  resource_group_name      = module.core.resource_group_name
  zone_name                = module.core.dns_zone_name
  service_plan_id          = module.core.app_service_plan_id
  application_insights_key = module.core.application_insights_key # Ensure the core module outputs this value
  repository_url           = "https://github.com/rbarrimond/baldwin-static.git"
  repository_token         = var.github_token
  default_tags = {
    environment = local.env
    project     = "baldwin"
  }
}
