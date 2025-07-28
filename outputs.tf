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
