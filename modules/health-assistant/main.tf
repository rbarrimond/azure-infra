# Storage Account for health data (separate from core)
resource "azurerm_storage_account" "health" {
  name                     = "sthealthprod${substr(replace(var.suffix, "-", ""), -4, 4)}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.storage_account_tier
  account_replication_type = var.storage_replication_type
  tags                     = var.default_tags
}

# Table Storage tables for workouts
resource "azurerm_storage_table" "workouts" {
  name                 = var.table_names.workouts
  storage_account_name = azurerm_storage_account.health.name
}

resource "azurerm_storage_table" "weekly_rollups" {
  name                 = var.table_names.weekly_rollups
  storage_account_name = azurerm_storage_account.health.name
}

resource "azurerm_storage_table" "ingestion_state" {
  name                 = var.table_names.ingestion_state
  storage_account_name = azurerm_storage_account.health.name
}

resource "azurerm_storage_table" "physiometrics" {
  name                 = var.table_names.physiometrics
  storage_account_name = azurerm_storage_account.health.name
}

# Blob container for backups (read-only)
resource "azurerm_storage_container" "backups" {
  name                  = var.backup_container_name
  storage_account_id    = azurerm_storage_account.health.id
  container_access_type = var.backup_container_access_type
}

# Lifecycle policy: move backups to cool tier after configured days, delete after configured days
resource "azurerm_storage_management_policy" "backup_lifecycle" {
  storage_account_id = azurerm_storage_account.health.id

  rule {
    name    = "backup-lifecycle"
    enabled = true
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["${var.backup_container_name}/"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = var.backup_lifecycle_cool_tier_days
        delete_after_days_since_modification_greater_than       = var.backup_lifecycle_delete_days
      }
    }
  }
}

# Azure Functions App (consumption plan, Python 3.12)
resource "azurerm_linux_function_app" "health_assistant" {
  name                        = "func-${var.suffix}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  service_plan_id             = var.service_plan_id
  storage_account_name        = azurerm_storage_account.health.name
  storage_account_access_key  = azurerm_storage_account.health.primary_access_key
  functions_extension_version = var.function_extension_version
  https_only                  = true
  tags                        = var.default_tags

  # Application settings
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"                  = "1"
    "APPINSIGHTS_INSTRUMENTATIONKEY"            = var.application_insights_key
    "ApplicationInsightsAgent_EXTENSION_VERSION" = var.application_insights_extension_version
    "AzureWebJobsStorage"                       = azurerm_storage_account.health.primary_connection_string
    "AZURE_STORAGE_ACCOUNT_URL"                 = azurerm_storage_account.health.primary_blob_endpoint
    "PUBLIC_BASE_URL"                           = "https://${var.dns_subdomain}.${var.zone_name}"
    "DEFAULT_ATHLETE_ID"                        = var.default_athlete_id
    "DEFAULT_FTP"                               = var.default_ftp
    "DEFAULT_MAX_HR"                            = var.default_max_hr
    "HR_ZONE_BASIS"                             = var.hr_zone_basis
    "HR_ZONE_REFERENCE_BPM"                     = var.hr_zone_reference_bpm
    "HR_RESTING_BPM"                            = var.hr_resting_bpm
    "ONEDRIVE_FOLDER_PATH"                      = var.onedrive_folder_path
    "KEYVAULT_URL"                              = var.key_vault_url
  }

  site_config {
    always_on                = false # consumption plan doesn't support always_on
    application_insights_key = var.application_insights_key
    cors {
      allowed_origins = var.cors_allowed_origins
    }
    application_stack {
      python_version = var.python_version
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
      app_settings["APPINSIGHTS_INSTRUMENTATIONKEY"]
    ]
  }
}

# Managed Identity access to Key Vault
resource "azurerm_key_vault_access_policy" "function_identity" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_linux_function_app.health_assistant.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List",
  ]
}

# DNS CNAME for health assistant API
resource "azurerm_dns_cname_record" "health_api" {
  name                = var.dns_subdomain
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = var.dns_ttl
  record              = azurerm_linux_function_app.health_assistant.default_hostname
}

# Bind custom hostname to the Function App
resource "azurerm_app_service_custom_hostname_binding" "health_custom_domain" {
  hostname            = "${var.dns_subdomain}.${var.zone_name}"
  app_service_name    = azurerm_linux_function_app.health_assistant.name
  resource_group_name = var.resource_group_name
}

# Issue a free managed certificate for the custom hostname
resource "azurerm_app_service_managed_certificate" "health_cert" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.health_custom_domain.id
}

# Bind the managed certificate to the hostname (SNI)
resource "azurerm_app_service_certificate_binding" "health_ssl" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.health_custom_domain.id
  certificate_id      = azurerm_app_service_managed_certificate.health_cert.id
  ssl_state           = "SniEnabled"
}

# Key Vault secret for Withings client credentials (placeholder)
resource "azurerm_key_vault_secret" "withings_client_id" {
  name         = "withings-client-id"
  value        = var.withings_client_id
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "withings_client_secret" {
  name         = "withings-client-secret"
  value        = var.withings_client_secret
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "withings_refresh_token" {
  name         = "withings-refresh-token"
  value        = var.withings_refresh_token
  key_vault_id = var.key_vault_id
}
