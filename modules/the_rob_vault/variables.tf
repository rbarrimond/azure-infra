variable "resource_group_name" {
  description = "The name of the resource group where resources will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
}

variable "suffix" {
  description = "A suffix to be appended to resource names."
  type        = string
}

variable "default_tags" {
  description = "Default tags to be applied to all resources."
  type        = map(string)
  default     = {}
}

variable "service_plan_id" {
  description = "The ID of the service plan to be used for the function app."
  type        = string
}

variable "application_insights_key" {
  description = "The instrumentation key for Application Insights."
  type        = string
}

variable "bungie_client_id" {
  description = "Bungie OAuth Client ID"
  type        = string
  sensitive   = true
}

variable "bungie_client_secret" {
  description = "Bungie OAuth Client Secret"
  type        = string
  sensitive   = true
}

variable "bungie_redirect_uri" {
  description = "Bungie OAuth Redirect URI"
  type        = string
  sensitive   = true
}

variable "zone_name" {
  description = "The DNS zone name in which to create the CNAME record for the Rob Vault app"
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Azure Key Vault to store secrets."
  type        = string
}

variable "bungie_api_key" {
  description = "Bungie API Key."
  type        = string
  sensitive   = true
}
