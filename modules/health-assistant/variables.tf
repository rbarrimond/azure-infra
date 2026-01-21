variable "resource_group_name" {
  description = "The name of the resource group where resources will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
}

variable "zone_name" {
  description = "The DNS zone name for API endpoint."
  type        = string
}

variable "suffix" {
  description = "A suffix to be appended to resource names."
  type        = string
}

variable "service_plan_id" {
  description = "The ID of the App Service plan (must support consumption)."
  type        = string
}

variable "application_insights_key" {
  description = "The instrumentation key for Application Insights."
  type        = string
  sensitive   = true
}

variable "log_analytics_workspace_id" {
  description = "The workspace ID for Log Analytics."
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Key Vault for storing secrets."
  type        = string
}

variable "key_vault_url" {
  description = "The URL of the Key Vault."
  type        = string
}

variable "tenant_id" {
  description = "The Azure tenant ID."
  type        = string
}

variable "default_tags" {
  description = "Default tags to be applied to all resources."
  type        = map(string)
  default     = {}
}

variable "withings_client_id" {
  description = "Withings API client ID (can be empty initially)."
  type        = string
  sensitive   = true
  default     = ""
}

variable "withings_client_secret" {
  description = "Withings API client secret (can be empty initially)."
  type        = string
  sensitive   = true
  default     = ""
}

variable "withings_refresh_token" {
  description = "Withings API refresh token (can be empty initially)."
  type        = string
  sensitive   = true
  default     = ""
}
