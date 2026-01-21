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
      version = "~> 4.0"
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
  source                               = "./modules/the_rob_vault"
  suffix                               = "therobvault-${var.environment}-${random_string.module_suffix.result}"
  location                             = var.region
  tenant_id                            = var.tenant_id
  resource_group_name                  = module.core.resource_group_name
  zone_name                            = module.core.dns_zone_name
  service_plan_id                      = module.core.app_service_plan_id
  application_insights_key             = module.core.application_insights_key
  key_vault_id                         = module.core.key_vault_id
  sql_server_name                      = module.core.sql_server_name
  bungie_client_id                     = var.bungie_client_id
  bungie_client_secret                 = var.bungie_client_secret
  bungie_redirect_uri                  = var.bungie_redirect_uri
  bungie_api_key                       = var.bungie_api_key
  log_analytics_workspace_id           = module.core.application_insights_workspace_id
  cognitive_account_name               = module.core.cognitive_account_name
  kv_sql_admin_login_versionless_id    = module.core.kv_sql_admin_login_versionless_id
  kv_sql_admin_password_versionless_id = module.core.kv_sql_admin_password_versionless_id

  default_tags = {
    environment = var.environment
    project     = "therobvault"
  }
}

module "health_assistant" {
  source                      = "./modules/health-assistant"
  suffix                      = "healthassistant-${var.environment}-${random_string.module_suffix.result}"
  location                    = var.region
  resource_group_name         = module.core.resource_group_name
  zone_name                   = module.core.dns_zone_name
  service_plan_id             = module.core.app_service_plan_id
  application_insights_key    = module.core.application_insights_key
  log_analytics_workspace_id  = module.core.application_insights_workspace_id
  key_vault_id                = module.core.key_vault_id
  key_vault_url               = "https://${module.core.key_vault_name}.vault.azure.net/"
  tenant_id                   = var.tenant_id
  withings_client_id          = var.withings_client_id != null ? var.withings_client_id : ""
  withings_client_secret      = var.withings_client_secret != null ? var.withings_client_secret : ""
  withings_refresh_token      = var.withings_refresh_token != null ? var.withings_refresh_token : ""
  default_max_hr              = var.default_max_hr
  default_ftp                 = var.default_ftp
  hr_zone_basis               = var.hr_zone_basis
  hr_zone_reference_bpm       = var.hr_zone_reference_bpm
  default_tags = {
    environment = var.environment
    project     = "health-assistant"
  }
}
