
variable "onedrive_folder_path" {
  description = "OneDrive folder path for health data."
  type        = string
  default     = "/Apps/HealthFit"
}

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

variable "github_actions_repo" {
  description = "GitHub org/repo used by the OIDC federated credential."
  type        = string
  default     = "rbarrimond/azure-infra"
}

variable "github_actions_branch" {
  description = "GitHub branch used by the OIDC federated credential."
  type        = string
  default     = "static"
}

variable "withings_client_id" {
  description = "Withings API client ID"
  type        = string
  sensitive   = true
  default     = null
}

variable "withings_client_secret" {
  description = "Withings API client secret"
  type        = string
  sensitive   = true
  default     = null
}

variable "withings_refresh_token" {
  description = "Withings API refresh token"
  type        = string
  sensitive   = true
  default     = null
}






variable "default_max_hr" {
  description = "Default maximum heart rate (bpm) passed to health assistant module."
  type        = string
  default     = "190"
}

variable "default_ftp" {
  description = "Default Functional Threshold Power (watts) passed to health assistant module."
  type        = string
  default     = "250"
}

variable "hr_zone_basis" {
  description = "Basis for heart rate zone calculations passed to health assistant module."
  type        = string
  default     = "HRmax"
}

variable "hr_zone_reference_bpm" {
  description = "Reference BPM (e.g., LTHR) passed to health assistant module."
  type        = string
  default     = "0"
}

variable "health_assistant_plugin_logo_url" {
  description = "Logo URL for Health Assistant ChatGPT Actions plugin."
  type        = string
  default     = "https://via.placeholder.com/128.png?text=Health+Assistant"
}

variable "health_assistant_plugin_contact_email" {
  description = "Contact email for Health Assistant ChatGPT Actions plugin."
  type        = string
  default     = "rbarrimond+health-assistant@users.noreply.github.com"
}

variable "health_assistant_plugin_legal_url" {
  description = "Legal info URL for Health Assistant ChatGPT Actions plugin."
  type        = string
  default     = "https://github.com/rbarrimond/health_assistant/blob/main/README.md"
}

variable "onedrive_client_id" {
  description = "OneDrive (personal) OAuth client ID."
  type        = string
  default     = ""
}

variable "onedrive_client_secret" {
  description = "OneDrive (personal) OAuth client secret."
  type        = string
  default     = ""
}

variable "onedrive_redirect_uri" {
  description = "OneDrive OAuth redirect URI."
  type        = string
  default     = ""
}

variable "onedrive_redirect_uris" {
  description = "Optional list of OneDrive OAuth redirect URIs for the app registration."
  type        = list(string)
  default     = []
}

variable "create_onedrive_app_registration" {
  description = "Whether to create the OneDrive app registration in Azure AD."
  type        = bool
  default     = false
}

variable "onedrive_app_display_name" {
  description = "Display name for the OneDrive Azure AD app registration."
  type        = string
  default     = ""
}

variable "onedrive_scopes" {
  description = "OneDrive OAuth scopes."
  type        = string
  default     = "Files.ReadWrite offline_access"
}

variable "onedrive_sync_lookback_days" {
  description = "Default lookback window (days) for OneDrive sync."
  type        = number
  default     = 30
}
variable "garmin_email" {
  description = "Garmin account email address."
  type        = string
  sensitive   = true
}

variable "garmin_password" {
  description = "Garmin account password."
  type        = string
  sensitive   = true
}

variable "garmin_sync_lookback_days" {
  description = "Default lookback window (days) for Garmin sync."
  type        = number
  default     = 30
}