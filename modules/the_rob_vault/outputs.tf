output "name" {
  value = azurerm_linux_function_app.the_rob_vault.name
}

output "fqdn" {
  value = azurerm_linux_function_app.the_rob_vault.default_hostname
}

output "custom_fqdn" {
  value = "https://${azurerm_dns_cname_record.the_rob_vault.name}.${var.zone_name}"
}
