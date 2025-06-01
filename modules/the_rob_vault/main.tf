resource "azurerm_storage_account" "the_rob_vault_storage" {
  name                     = "sa${substr(replace(lower(var.suffix), "-", ""), 0, 19)}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.default_tags
}

resource "azurerm_key_vault_secret" "bungie_client_id" {
  name         = "BUNGIE-CLIENT-ID"
  value        = var.bungie_client_id
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "bungie_client_secret" {
  name         = "BUNGIE-CLIENT-SECRET"
  value        = var.bungie_client_secret
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "bungie_redirect_uri" {
  name         = "BUNGIE-REDIRECT-URI"
  value        = var.bungie_redirect_uri
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "bungie_api_key" {
  name         = "BUNGIE-API-KEY"
  value        = var.bungie_api_key
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "storage_connection_string" {
  name         = "AZURE-STORAGE-CONNECTION-STRING"
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

    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "BUNGIE_CLIENT_ID"                = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.bungie_client_id.id})"
    "BUNGIE_CLIENT_SECRET"            = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.bungie_client_secret.id})"
    "BUNGIE_REDIRECT_URI"             = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.bungie_redirect_uri.id})"
    "BUNGIE_API_KEY"                  = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.bungie_api_key.id})"
    "AZURE_STORAGE_CONNECTION_STRING" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.storage_connection_string.id})"
    "SCM_DO_BUILD_DURING_DEPLOYMENT"  = "1"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_dns_cname_record" "the_rob_vault" {
  name                = "therobvault"
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = azurerm_linux_function_app.the_rob_vault.default_hostname
}

output "name" {
  value = azurerm_linux_function_app.the_rob_vault.name
}

output "fqdn" {
  value = azurerm_linux_function_app.the_rob_vault.default_hostname
}

output "custom_fqdn" {
  value = "https://${azurerm_dns_cname_record.the_rob_vault.name}.${var.zone_name}"
}
