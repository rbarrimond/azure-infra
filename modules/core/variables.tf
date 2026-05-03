variable "region" {
  type    = string
  default = "eastus"
}

variable "suffix" {
  type    = string
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

variable "postgres_version" {
  description = "PostgreSQL major version for Azure Database for PostgreSQL Flexible Server."
  type        = string
  default     = "16"
}

variable "postgres_sku_name" {
  description = "Compute SKU name for Azure Database for PostgreSQL Flexible Server."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "postgres_storage_mb" {
  description = "Allocated storage in MB for PostgreSQL Flexible Server."
  type        = number
  default     = 32768
}

variable "postgres_backup_retention_days" {
  description = "Backup retention in days for PostgreSQL Flexible Server."
  type        = number
  default     = 7
}

variable "postgres_public_network_access_enabled" {
  description = "Enable public network access for PostgreSQL Flexible Server."
  type        = bool
  default     = true
}

variable "postgres_allow_azure_services" {
  description = "Allow connections from Azure services to PostgreSQL Flexible Server."
  type        = bool
  default     = true
}
