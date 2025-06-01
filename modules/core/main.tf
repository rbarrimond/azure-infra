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
  name                     = "kv-${var.suffix}"
  location                 = azurerm_resource_group.core.location
  resource_group_name      = azurerm_resource_group.core.name
  tenant_id                = var.tenant_id
  sku_name                 = "standard"
  purge_protection_enabled = false
  tags                     = var.default_tags
}

resource "azurerm_service_plan" "core" {
  name                = "asp-${var.suffix}"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  os_type             = "Linux"
  sku_name            = "B1"
  tags                = var.default_tags
}

resource "azurerm_application_insights" "core" {
  name                = "appi-${var.suffix}"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  application_type    = "web"
  tags                = var.default_tags
  lifecycle {
    ignore_changes = [
      workspace_id
    ]
  }
}

resource "azurerm_key_vault_access_policy" "terraform_sp" {
  key_vault_id = azurerm_key_vault.core.id
  tenant_id    = var.tenant_id
  object_id    = var.key_vault_admin_object_id

  secret_permissions = [
    "Get",
    "Set",
    "Delete",
    "List"
  ]
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
  value = azurerm_service_plan.core.id
}

output "application_insights_key" {
  value = azurerm_application_insights.core.instrumentation_key
}

output "key_vault_id" {
  value = azurerm_key_vault.core.id
}
