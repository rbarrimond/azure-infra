// outputs.tf placeholder
output "the_rob_vault_url" {
  value = "${module.the_rob_vault.custom_fqdn}"
}
