output "function_app_id" {
  description = "The ID of the Function App."
  value       = azurerm_linux_function_app.health_assistant.id
}

output "function_app_name" {
  description = "The name of the Function App."
  value       = azurerm_linux_function_app.health_assistant.name
}

output "function_app_default_hostname" {
  description = "The default hostname of the Function App."
  value       = azurerm_linux_function_app.health_assistant.default_hostname
}

output "storage_account_name" {
  description = "The name of the health data storage account."
  value       = azurerm_storage_account.health.name
}

output "storage_account_id" {
  description = "The ID of the health data storage account."
  value       = azurerm_storage_account.health.id
}

output "storage_primary_connection_string" {
  description = "The primary connection string for the storage account."
  value       = azurerm_storage_account.health.primary_connection_string
  sensitive   = true
}

output "api_endpoint" {
  description = "The public API endpoint for the health assistant."
  value       = "https://${azurerm_dns_cname_record.health_api.name}.${var.zone_name}"
}

output "function_app_identity_principal_id" {
  description = "The principal ID of the Function App's managed identity."
  value       = azurerm_linux_function_app.health_assistant.identity[0].principal_id
}

output "custom_hostname" {
  description = "The custom hostname bound to the Health Assistant Function App."
  value       = azurerm_app_service_custom_hostname_binding.health_custom_domain.hostname
}

output "managed_certificate_id" {
  description = "Resource ID of the managed certificate for the custom hostname."
  value       = azurerm_app_service_managed_certificate.health_cert.id
}
output "healthcheck_url" {
  description = "Health check endpoint for the Health Assistant Function App."
  value       = "https://${var.dns_subdomain}.${var.zone_name}/api/health"
}