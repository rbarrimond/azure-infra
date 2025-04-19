resource "azurerm_resource_group" "core" {
  name     = "rg-${var.suffix}"
  location = var.region
  tags     = var.default_tags
}

resource "azurerm_storage_account" "core" {
  name                     = "st${replace(lower(var.suffix), "-", "")}"
  resource_group_name      = azurerm_resource_group.core.name
  location                 = azurerm_resource_group.core.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.default_tags
}

resource "azurerm_dns_zone" "core" {
  name                = "azure.barrimond.net"
  resource_group_name = azurerm_resource_group.core.name
  tags                = var.default_tags
}

resource "azurerm_key_vault" "core" {
  name                        = "kv-${var.suffix}"
  location                    = azurerm_resource_group.core.location
  resource_group_name         = azurerm_resource_group.core.name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
  tags                        = var.default_tags
}

resource "azurerm_app_service_plan" "core" {
  name                = "asp-${var.suffix}"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }

  tags = var.default_tags
}

resource "azurerm_application_insights" "core" {
  name                = "appi-${var.suffix}"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  application_type    = "web"
  tags                = var.default_tags
}

output "resource_group_name" {
  value = azurerm_resource_group.core.name
}

output "storage_account_name" {
  value = azurerm_storage_account.core.name
}

output "dns_zone_name" {
  value = azurerm_dns_zone.core.name
}

output "key_vault_name" {
  value = azurerm_key_vault.core.name
}

output "app_service_plan_id" {
  value = azurerm_app_service_plan.core.id
}

output "application_insights_connection_string" {
  value = azurerm_application_insights.core.connection_string
}
