resource "azurerm_storage_account" "the_rob_vault_storage" {
  name                     = "sa${replace(lower(var.suffix), "-", "")}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.default_tags
}

resource "azurerm_linux_web_app" "the_rob_vault_flask" {
  name                = "lwa-${var.suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = var.service_plan_id
  tags                = var.default_tags

  site_config {
    always_on                = true

    application_stack {
      python_version = "3.11"
    }
  }

  app_settings = {
    "WEBSITES_PORT"                          = "5000"
    "BUNGIE_CLIENT_ID"                       = var.bungie_client_id
    "BUNGIE_CLIENT_SECRET"                   = var.bungie_client_secret
    "BUNGIE_REDIRECT_URI"                    = var.bungie_redirect_uri
    "SCM_DO_BUILD_DURING_DEPLOYMENT"         = "1"
    "APPLICATIONINSIGHTS_INSTRUMENTATIONKEY" = var.application_insights_key
  }

  identity {
    type = "SystemAssigned"
  }
}
