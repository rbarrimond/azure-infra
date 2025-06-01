// outputs.tf placeholder
output "the_rob_vault_url" {
  value = "https://${module.the_rob_vault.fqdn}"
}

