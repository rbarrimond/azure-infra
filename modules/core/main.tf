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
  account_kind             = "StorageV2"
}

resource "azuread_service_principal" "github_actions_sp" {
  client_id = var.github_actions_sp_client_id
}

resource "azurerm_role_assignment" "github_actions_blob_contributor" {
  scope                = azurerm_storage_account.core.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.github_actions_sp.object_id
}

resource "azurerm_storage_account_static_website" "static_website" {
  storage_account_id = azurerm_storage_account.core.id
  index_document     = "index.html"
  error_404_document = "404.html"
}

resource "azurerm_storage_container" "static_container" {
  name                  = "$web"
  storage_account_name  = azurerm_storage_account.core.name
  container_access_type = "blob"
}

resource "azurerm_dns_cname_record" "static_dns" {
  name                = "static"
  zone_name           = azurerm_dns_zone.core.name
  resource_group_name = azurerm_resource_group.core.name
  ttl                 = 300
  record              = azurerm_storage_account.core.primary_web_host
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
  sku_name            = "B2"
  tags                = var.default_tags
}

resource "azurerm_log_analytics_workspace" "core" {
  name                = "log-${var.suffix}"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.default_tags
}

resource "azurerm_application_insights" "core" {
  name                = "appi-${var.suffix}"
  location            = azurerm_resource_group.core.location
  resource_group_name = azurerm_resource_group.core.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.core.id
  tags                = var.default_tags

}

resource "azurerm_key_vault_access_policy" "terraform_sp" {
  key_vault_id = azurerm_key_vault.core.id
  tenant_id    = var.tenant_id
  object_id    = var.key_vault_admin_object_id

  secret_permissions = [
    "Get",
    "Set",
    "Delete",
    "List",
    "Purge",
  ]
}
resource "azurerm_key_vault_secret" "kv_sql_admin_login" {
  name         = "sqlAdminLogin"
  value        = "sqladmin-${var.suffix}"
  key_vault_id = azurerm_key_vault.core.id
}

resource "random_password" "sql_admin_password" {
  length           = 32
  special          = true
  override_special = "!@#%^&*()-_=+[]{}"
}

resource "azurerm_key_vault_secret" "kv_sql_admin_password" {
  name         = "sqlAdminPassword"
  value        = random_password.sql_admin_password.result
  key_vault_id = azurerm_key_vault.core.id
}
resource "azurerm_mssql_server" "core" {
  name                         = "sql-${var.suffix}"
  resource_group_name          = azurerm_resource_group.core.name
  location                     = azurerm_resource_group.core.location
  version                      = "12.0"
  administrator_login          = azurerm_key_vault_secret.kv_sql_admin_login.value
  administrator_login_password = azurerm_key_vault_secret.kv_sql_admin_password.value
  tags                         = var.default_tags
}

# resource "azurerm_mssql_database" "core" {
#   name                = "db-${var.suffix}"
#   server_id           = azurerm_mssql_server.core.id
#   sku_name            = "GP_S_Gen5_1" # General Purpose, Serverless, Gen5, 1 vCore
#   min_capacity        = 0.5            # Serverless minimum vCores
#   # max_capacity removed; not valid for azurerm_mssql_database
#   # Serverless scaling is managed by min_capacity and auto_pause_delay_in_minutes
#   auto_pause_delay_in_minutes = 60     # Auto-pause after 60 minutes inactivity
#   zone_redundant      = false
#   tags                = var.default_tags
# }


