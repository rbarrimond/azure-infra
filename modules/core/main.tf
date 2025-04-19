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

output "resource_group_name" {
  value = azurerm_resource_group.core.name
}

output "storage_account_name" {
  value = azurerm_storage_account.core.name
}
