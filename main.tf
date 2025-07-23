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

module "core" {
  source                      = "./modules/core"
  suffix                      = "core-${var.environment}-${random_string.module_suffix.result}"
  tenant_id                   = var.tenant_id
  region                      = var.region
  key_vault_admin_object_id   = var.key_vault_admin_object_id
  github_actions_sp_client_id = var.github_actions_sp_client_id
  default_tags = {
    environment = var.environment
    project     = "core"
  }
}

module "baldwin" {
  source                   = "./modules/baldwin"
  suffix                   = "baldwin-${var.environment}-${random_string.module_suffix.result}"
  location                 = var.region
  resource_group_name      = module.core.resource_group_name
  zone_name                = module.core.dns_zone_name
  service_plan_id          = module.core.app_service_plan_id
  application_insights_key = module.core.application_insights_key # Ensure the core module outputs this value
  repository_url           = "https://github.com/rbarrimond/baldwin-static.git"
  repository_token         = var.github_token
  default_tags = {
    environment = var.environment
    project     = "baldwin"
  }
}

module "the_rob_vault" {
  source                     = "./modules/the_rob_vault"
  suffix                     = "therobvault-${var.environment}-${random_string.module_suffix.result}"
  location                   = var.region
  tenant_id                  = var.tenant_id
  resource_group_name        = module.core.resource_group_name
  zone_name                  = module.core.dns_zone_name
  service_plan_id            = module.core.app_service_plan_id
  application_insights_key   = module.core.application_insights_key
  key_vault_id               = module.core.key_vault_id
  bungie_client_id           = var.bungie_client_id
  bungie_client_secret       = var.bungie_client_secret
  bungie_redirect_uri        = var.bungie_redirect_uri
  bungie_api_key             = var.bungie_api_key
  log_analytics_workspace_id = module.core.application_insights_workspace_id

  default_tags = {
    environment = var.environment
    project     = "therobvault"
  }
}
