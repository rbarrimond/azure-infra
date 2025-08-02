output "sql_server_name" {
  description = "The name of the Azure SQL Server."
  value       = azurerm_mssql_server.core.name
}

output "sql_server_fqdn" {
  description = "The fully qualified domain name of the Azure SQL Server."
  value       = azurerm_mssql_server.core.fully_qualified_domain_name
}

output "kv_sql_admin_login_versionless_id" {
  description = "The versionless ID of the Key Vault secret for the SQL admin login."
  value       = azurerm_key_vault_secret.kv_sql_admin_login.versionless_id
}

output "kv_sql_admin_password_versionless_id" {
  description = "The versionless ID of the Key Vault secret for the SQL admin password."
  value       = azurerm_key_vault_secret.kv_sql_admin_password.versionless_id
}

output "application_insights_key" {
  description = "The instrumentation key for Application Insights."
  value       = azurerm_application_insights.core.instrumentation_key
  sensitive   = true
}
output "resource_group_name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.core.name
}

output "storage_account_name" {
  description = "The name of the storage account."
  value       = azurerm_storage_account.core.name
}

output "static_website_url" {
  description = "The primary web endpoint URL for the static website."
  value       = azurerm_storage_account.core.primary_web_endpoint
}

output "dns_zone_name" {
  description = "The name of the DNS zone."
  value       = azurerm_dns_zone.core.name
}

output "key_vault_name" {
  description = "The name of the Key Vault."
  value       = azurerm_key_vault.core.name
}

output "app_service_plan_id" {
  description = "The ID of the App Service plan."
  value       = azurerm_service_plan.core.id
}


output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.core.id
}

output "application_insights_workspace_id" {
  description = "The workspace ID for Application Insights."
  value       = azurerm_application_insights.core.workspace_id
}

output "cognitive_account_name" {
  description = "The name of the Azure Cognitive Services account."
  value       = azurerm_cognitive_account.core.name
}
