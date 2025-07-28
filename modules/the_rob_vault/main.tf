resource "azurerm_mssql_database" "the_rob_vault_db" {
  name                        = "db-${var.suffix}"
  server_id                   = var.sql_server_id
  sku_name                    = "GP_S_Gen5_1" # General Purpose, Serverless, Gen5, 1 vCore
  min_capacity                = 0.5           # Serverless minimum vCores
  auto_pause_delay_in_minutes = 60            # Auto-pause after 60 minutes inactivity
  zone_redundant              = false
  tags                        = var.default_tags
}

resource "azurerm_storage_account" "the_rob_vault_storage" {
  name                     = "sa${substr(replace(lower(var.suffix), "-", ""), 0, 19)}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.default_tags
}

resource "azurerm_key_vault_secret" "bungieClientId" {
  name         = "bungieClientId"
  value        = var.bungie_client_id
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "bungieClientSecret" {
  name         = "bungieClientSecret"
  value        = var.bungie_client_secret
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "bungieRedirectUri" {
  name         = "bungieRedirectUri"
  value        = var.bungie_redirect_uri
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "bungieApiKey" {
  name         = "bungieApiKey"
  value        = var.bungie_api_key
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "storageConnectionString" {
  name         = "storageConnectionString"
  value        = azurerm_storage_account.the_rob_vault_storage.primary_connection_string
  key_vault_id = var.key_vault_id
}

resource "azurerm_linux_function_app" "the_rob_vault" {
  name                       = "lfa-${var.suffix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = var.service_plan_id
  storage_account_name       = azurerm_storage_account.the_rob_vault_storage.name
  storage_account_access_key = azurerm_storage_account.the_rob_vault_storage.primary_access_key
  tags                       = var.default_tags

  site_config {
    always_on                = true
    application_insights_key = var.application_insights_key
    health_check_path        = "/api/health"

    application_stack {
      python_version = "3.10"
    }
  }

  app_settings = {
    "BUNGIE_CLIENT_ID"                = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.bungieClientId.versionless_id})"
    "BUNGIE_CLIENT_SECRET"            = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.bungieClientSecret.versionless_id})"
    "BUNGIE_REDIRECT_URI"             = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.bungieRedirectUri.versionless_id})"
    "BUNGIE_API_KEY"                  = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.bungieApiKey.versionless_id})"
    "AZURE_STORAGE_CONNECTION_STRING" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.storageConnectionString.versionless_id})"
    "WEBSITE_RUN_FROM_PACKAGE"        = "0"
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings["BUILD_FLAGS"],
      app_settings["ENABLE_ORYX_BUILD"],
      app_settings["SCM_DO_BUILD_DURING_DEPLOYMENT"],
      app_settings["XDG_CACHE_HOME"]
    ]
  }
}

resource "azurerm_dns_cname_record" "the_rob_vault" {
  name                = "therobvault"
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = azurerm_linux_function_app.the_rob_vault.default_hostname
}

resource "azurerm_app_service_custom_hostname_binding" "the_rob_vault" {
  hostname            = "therobvault.${var.zone_name}"
  app_service_name    = azurerm_linux_function_app.the_rob_vault.name
  resource_group_name = var.resource_group_name
}

resource "azurerm_app_service_managed_certificate" "the_rob_vault_cert" {
  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.the_rob_vault.id
}

resource "azurerm_app_service_certificate_binding" "the_rob_vault_tls" {
  hostname_binding_id = azurerm_app_service_custom_hostname_binding.the_rob_vault.id
  certificate_id      = azurerm_app_service_managed_certificate.the_rob_vault_cert.id
  ssl_state           = "SniEnabled"
}

resource "azurerm_monitor_diagnostic_setting" "the_rob_vault_function" {
  name                       = "diag-${var.suffix}"
  target_resource_id         = azurerm_linux_function_app.the_rob_vault.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "FunctionAppLogs"
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

resource "azurerm_key_vault_access_policy" "the_rob_vault_function" {
  key_vault_id = var.key_vault_id
  tenant_id    = var.tenant_id
  object_id    = azurerm_linux_function_app.the_rob_vault.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List",
    "Purge"
  ]
}

