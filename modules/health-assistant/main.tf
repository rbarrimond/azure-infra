# Storage Account for health data (separate from core)
resource "azurerm_storage_account" "health" {
  name                     = "sthealthprod${substr(replace(var.suffix, "-", ""), -4, 4)}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.default_tags
}

# Table Storage tables for workouts
resource "azurerm_storage_table" "workouts" {
  name                 = "Workouts"
  storage_account_name = azurerm_storage_account.health.name
}

resource "azurerm_storage_table" "weekly_rollups" {
  name                 = "WeeklyRollups"
  storage_account_name = azurerm_storage_account.health.name
}

resource "azurerm_storage_table" "ingestion_state" {
  name                 = "IngestionState"
  storage_account_name = azurerm_storage_account.health.name
}

resource "azurerm_storage_table" "physiometrics" {
  name                 = "Physiometrics"
  storage_account_name = azurerm_storage_account.health.name
}

# Blob container for backups (read-only)
resource "azurerm_storage_container" "backups" {
  name                  = "backups"
  storage_account_id    = azurerm_storage_account.health.id
  container_access_type = "private"
}

# Lifecycle policy: move backups to cool tier after 30 days, delete after 90 days
resource "azurerm_storage_management_policy" "backup_lifecycle" {
  storage_account_id = azurerm_storage_account.health.id

  rule {
    name    = "backup-lifecycle"
    enabled = true
    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["backups/"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than = 30
        delete_after_days_since_modification_greater_than       = 90
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
  functions_extension_version = "~4"
  https_only                  = true
  tags                        = var.default_tags

  # Application settings
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"                  = "1"
    "APPINSIGHTS_INSTRUMENTATIONKEY"            = var.application_insights_key
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "AzureWebJobsStorage"                       = azurerm_storage_account.health.primary_connection_string
    "AZURE_STORAGE_ACCOUNT_URL"                 = azurerm_storage_account.health.primary_blob_endpoint
    "DEFAULT_ATHLETE_ID"                        = "rob"
    "DEFAULT_FTP"                               = "250"
    "DEFAULT_MAX_HR"                            = "190"
    "HR_ZONE_BASIS"                             = "HRmax"
    "HR_ZONE_REFERENCE_BPM"                     = "0"
    "HR_RESTING_BPM"                            = "60"
    "ONEDRIVE_FOLDER_PATH"                      = "/Apps/HealthFit"
    "KEYVAULT_URL"                              = var.key_vault_url
  }

  site_config {
    always_on                = false # consumption plan doesn't support always_on
    application_insights_key = var.application_insights_key
    application_stack {
      python_version = "3.12"
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
  name                = "health"
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = azurerm_linux_function_app.health_assistant.default_hostname
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
