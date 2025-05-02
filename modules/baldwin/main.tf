resource "azurerm_dns_cname_record" "baldwin_static" {
  name                = "baldwin"
  zone_name           = var.zone_name
  resource_group_name = var.dns_rg
  ttl                 = 300
  record              = "<your-static-app>.z13.web.core.windows.net"
}

resource "azurerm_dns_cname_record" "baldwin_api" {
  name                = "baldwin-api"
  zone_name           = var.zone_name
  resource_group_name = var.dns_rg
  ttl                 = 300
  record              = "<your-function-app>.azurewebsites.net"
}

resource "azurerm_storage_account" "gpt_static" {
  name                     = "gptpluginstore"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  static_website {
    index_document = "index.html"
    error_404_document = "404.html"
  }
}

resource "azurerm_storage_blob" "ai_plugin" {
  name                   = ".well-known/ai-plugin.json"
  storage_account_name   = azurerm_storage_account.gpt_static.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "${path.module}/public/.well-known/ai-plugin.json"
  content_type           = "application/json"
}

resource "azurerm_storage_blob" "openapi" {
  name                   = "openapi.yaml"
  storage_account_name   = azurerm_storage_account.gpt_static.name
  storage_container_name = "$web"
  type                   = "Block"
  source                 = "${path.module}/public/openapi.yaml"
  content_type           = "application/x-yaml"
}