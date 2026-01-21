output "core_resource_group_name" {
  value = module.core.resource_group_name
}

output "core_storage_account_name" {
  value = module.core.storage_account_name
}

output "core_static_website_url" {
  value = module.core.static_website_url
}

output "core_dns_zone_name" {
  value = module.core.dns_zone_name
}

output "core_key_vault_name" {
  value = module.core.key_vault_name
}

output "core_app_service_plan_id" {
  value = module.core.app_service_plan_id
}

output "core_key_vault_id" {
  value = module.core.key_vault_id
}

output "core_application_insights_workspace_id" {
  value = module.core.application_insights_workspace_id
}

output "core_sql_server_url" {
  value = module.core.sql_server_fqdn
}

# The Rob Vault Outputs
output "the_rob_vault_function_app_name" {
  value = module.the_rob_vault.function_app_name
}
output "the_rob_vault_function_app_fqdn" {
  value = module.the_rob_vault.function_app_fqdn
}
output "the_rob_vault_custom_fqdn" {
  value = module.the_rob_vault.custom_fqdn
}
output "the_rob_vault_db_name" {
  value = module.the_rob_vault.db_name
}

# Health Assistant Outputs
output "health_assistant_function_app_name" {
  value       = module.health_assistant.function_app_name
  description = "The name of the Health Assistant Function App"
}

output "health_assistant_function_app_default_hostname" {
  value       = module.health_assistant.function_app_default_hostname
  description = "The default hostname of the Health Assistant Function App"
}

output "health_assistant_api_endpoint" {
  value       = module.health_assistant.api_endpoint
  description = "The public API endpoint for the Health Assistant"
}

output "health_assistant_storage_account_name" {
  value       = module.health_assistant.storage_account_name
  description = "The name of the Health Assistant storage account"
}

output "health_assistant_function_app_id" {
  value       = module.health_assistant.function_app_id
  description = "The ID of the Health Assistant Function App"
}

output "health_assistant_function_app_identity_principal_id" {
  value       = module.health_assistant.function_app_identity_principal_id
  description = "The principal ID of the Health Assistant Function App's managed identity"
} 