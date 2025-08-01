variable "region" {
  type = string
  default = "eastus"
}

variable "suffix" {
  type = string
  default = "rrb01"
}

variable "default_tags" {
  type = map(string)
}

variable "tenant_id" {
  description = "The tenant ID for the Azure account"
  type        = string
}

variable "key_vault_admin_object_id" {
  description = "The object ID of the user or service principal to be granted Key Vault admin permissions."
  type        = string
}

variable "github_actions_sp_client_id" {
  description = "The client ID of the GitHub Actions service principal for blob contributor role assignment."
  type        = string
}