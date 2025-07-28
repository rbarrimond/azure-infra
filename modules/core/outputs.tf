output "sql_server_name" {
  description = "The name of the Azure SQL Server."
  value       = azurerm_mssql_server.core.name
}

output "sql_server_fqdn" {
  description = "The fully qualified domain name of the Azure SQL Server."
  value       = azurerm_mssql_server.core.fully_qualified_domain_name
}
output "application_insights_key" {
  value     = azurerm_application_insights.core.instrumentation_key
  sensitive = true
}
output "resource_group_name" {
  value = azurerm_resource_group.core.name
}

output "storage_account_name" {
  value = azurerm_storage_account.core.name
}

output "static_website_url" {
  value = azurerm_storage_account.core.primary_web_endpoint
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


output "key_vault_id" {
  value = azurerm_key_vault.core.id
}

output "application_insights_workspace_id" {
  value = azurerm_application_insights.core.workspace_id
}

