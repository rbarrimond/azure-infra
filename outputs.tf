// outputs.tf - Key outputs for CLI and automation

// outputs.tf - Key outputs for CLI and automation

output "function_app_name" {
  description = "Name of the Azure Function App"
  value       = module.the_rob_vault.linux_function_app_name
}

output "function_app_id" {
  description = "Resource ID of the Azure Function App"
  value       = module.the_rob_vault.linux_function_app_id
}

output "function_default_hostname" {
  description = "Default hostname of the Azure Function App"
  value       = module.the_rob_vault.function_default_hostname
}

output "function_custom_fqdn" {
  description = "Custom FQDN for the Function App (if set)"
  value       = module.the_rob_vault.custom_fqdn
}

output "resource_group_name" {
  description = "Resource group name"
  value       = module.the_rob_vault.resource_group_name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = module.the_rob_vault.storage_account_name
}

output "storage_account_id" {
  description = "Resource ID of the storage account"
  value       = module.the_rob_vault.storage_account_id
}

output "key_vault_id" {
  description = "Resource ID of the Key Vault"
  value       = module.the_rob_vault.key_vault_id
}

output "dns_zone_name" {
  description = "DNS zone name"
  value       = module.the_rob_vault.zone_name
}

output "subscription_id" {
  description = "Azure Subscription ID"
  value       = data.azurerm_client_config.current.subscription_id
}

output "location" {
  description = "Azure region/location"
  value       = module.the_rob_vault.location
}
