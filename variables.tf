variable "subscription_id" {
  description = "The subscription ID for the Azure account"
  type        = string
}

variable "tenant_id" {
  description = "The tenant ID for the Azure account"
  type        = string
}

variable "region" {
  description = "The Azure region where resources will be deployed"
  type        = string
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, prod)"
  type        = string
  default     = "prod"
}

variable "github_token" {
  description = "GitHub token for accessing the repository"
  type        = string
  sensitive   = true
}

variable "bungie_client_id" {
  description = "Bungie API client ID"
  type        = string
  sensitive   = true
}

variable "bungie_client_secret" {
  description = "Bungie API client secret"
  type        = string
  sensitive   = true
}

variable "bungie_redirect_uri" {
  description = "Bungie API redirect URI"
  type        = string
  sensitive   = true
}

variable "bungie_api_key" {
  description = "Bungie API Key."
  type        = string
  sensitive   = true
}

variable "key_vault_admin_object_id" {
  description = "The object ID of the user or service principal to be granted Key Vault admin permissions."
  type        = string
}

variable "github_actions_sp_client_id" {
  description = "The client ID of the GitHub Actions service principal for blob contributor role assignment."
  type        = string
}