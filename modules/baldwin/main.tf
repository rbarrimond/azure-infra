resource "azurerm_static_web_app" "baldwin_web" {
  name                = "swa-${var.suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_tier            = "Standard"
  sku_size            = "Standard"
  tags                = var.default_tags
}

resource "azurerm_dns_cname_record" "baldwin_web" {
  name                = "baldwin"
  zone_name           = var.zone_name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  record              = azurerm_static_web_app.baldwin_web.default_host_name
}

resource "azurerm_static_web_app_custom_domain" "baldwin_domain" {
  static_web_app_id = azurerm_static_web_app.baldwin_web.id
  validation_type   = "cname-delegation"
  domain_name       = "${azurerm_dns_cname_record.baldwin_web.name}.${var.zone_name}"
}

resource "azurerm_storage_account" "baldwin_storage" {
  name                     = "sa${replace(lower(var.suffix), "-", "")}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.default_tags
}

resource "azurerm_linux_function_app" "baldwin_function" {
  name                       = "lfa-${var.suffix}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = var.service_plan_id
  storage_account_name       = azurerm_storage_account.baldwin_storage.name
  storage_account_access_key = azurerm_storage_account.baldwin_storage.primary_access_key
  https_only                 = true
  tags                       = var.default_tags

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"                 = "1"
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = azurerm_storage_account.baldwin_storage.primary_blob_connection_string
    "WEBSITE_CONTENTSHARE"                     = azurerm_storage_account.baldwin_storage.name
    "AzureWebJobsStorage"                      = azurerm_storage_account.baldwin_storage.primary_blob_connection_string
    "FUNCTIONS_EXTENSION_VERSION"              = "~4"
  }
  site_config {
    always_on = true
    application_stack {
      python_version = "3.11"
    }
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"]
    ]
  }
}

resource "azurerm_static_web_app_function_app_registration" "baldwin_registration" {
  static_web_app_id = azurerm_static_web_app.baldwin_web.id
  function_app_id   = azurerm_linux_function_app.baldwin_function.id
}
