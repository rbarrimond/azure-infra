resource "azurerm_storage_account" "the_rob_vault_storage" {
  name                     = "therobvault${replace(lower(var.suffix), "-", "")}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.default_tags
}

resource "azurerm_linux_function_app" "the_rob_vault" {
  name                       = "the-rob-vault-${var.suffix}"
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
    "BUNGIE_CLIENT_ID"               = var.bungie_client_id
    "BUNGIE_CLIENT_SECRET"           = var.bungie_client_secret
    "BUNGIE_REDIRECT_URI"            = var.bungie_redirect_uri
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_dns_zone" "the_rob_vault_zone" {
  name                = var.zone_name
  resource_group_name = var.resource_group_name
  tags                = var.default_tags
}

resource "azurerm_dns_cname_record" "the_rob_vault" {
  name                = "the-rob-vault"
  zone_name           = azurerm_dns_zone.the_rob_vault_zone.name
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

output "dns_zone_name" {
  value = azurerm_dns_zone.the_rob_vault_zone.name
}

output "custom_domain" {
  value = azurerm_function_app_custom_hostname_binding.the_rob_vault_binding.hostname
}
