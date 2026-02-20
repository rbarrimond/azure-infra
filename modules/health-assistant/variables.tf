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
  description = "The ID of the App Service plan (for backward compatibility, no longer used)."
  type        = string
  default     = ""
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

variable "onedrive_client_id" {
  description = "OneDrive (personal) OAuth client ID."
  type        = string
  sensitive   = true
  default     = ""
}

variable "onedrive_client_secret" {
  description = "OneDrive (personal) OAuth client secret."
  type        = string
  sensitive   = true
  default     = ""
}

variable "onedrive_redirect_uri" {
  description = "OneDrive OAuth redirect URI."
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
  description = "Garmin Connect account email."
  type        = string
  sensitive   = true
  default     = ""
}

variable "garmin_password" {
  description = "Garmin Connect account password."
  type        = string
  sensitive   = true
  default     = ""
}

variable "garmin_sync_lookback_days" {
  description = "Default lookback window (days) for Garmin sync."
  type        = number
  default     = 30
}





variable "storage_account_tier" {
  description = "Performance tier for storage account."
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Replication type for storage account."
  type        = string
  default     = "LRS"
}

variable "table_names" {
  description = "Names of the storage tables to create."
  type = object({
    workouts        = string
    weekly_rollups  = string
    ingestion_state = string
    physiometrics   = string
    onedrive_tokens = string
  })
  default = {
    workouts        = "Workouts"
    weekly_rollups  = "WeeklyRollups"
    ingestion_state = "IngestionState"
    physiometrics   = "Physiometrics"
    onedrive_tokens = "OneDriveTokens"
  }
}

variable "backup_container_name" {
  description = "Name of the blob container for backups."
  type        = string
  default     = "backups"
}

variable "backup_container_access_type" {
  description = "Access type for backup container."
  type        = string
  default     = "private"
}

variable "backup_lifecycle_cool_tier_days" {
  description = "Days after modification before moving backups to cool tier."
  type        = number
  default     = 30
}

variable "backup_lifecycle_delete_days" {
  description = "Days after modification before deleting backups."
  type        = number
  default     = 90
}

variable "function_extension_version" {
  description = "Azure Functions runtime version."
  type        = string
  default     = "~4"
}

variable "python_version" {
  description = "Python runtime version for Function App."
  type        = string
  default     = "3.13"
}

variable "application_insights_extension_version" {
  description = "Application Insights extension version."
  type        = string
  default     = "~3"
}

variable "default_athlete_id" {
  description = "Default athlete ID for workouts."
  type        = string
  default     = "rob"
}

variable "default_ftp" {
  description = "Default Functional Threshold Power (watts)."
  type        = string
  default     = "250"
}

variable "default_max_hr" {
  description = "Default maximum heart rate (bpm)."
  type        = string
  default     = "190"
}

variable "hr_zone_basis" {
  description = "Basis for heart rate zone calculations."
  type        = string
  default     = "HRmax"
}

variable "hr_zone_reference_bpm" {
  description = "Reference BPM for heart rate zones."
  type        = string
  default     = "0"
}

variable "hr_resting_bpm" {
  description = "Resting heart rate (bpm)."
  type        = string
  default     = "60"
}

variable "onedrive_folder_path" {
  description = "OneDrive folder path for health data."
  type        = string
  default     = "/Apps/HealthFit"
}

variable "dns_ttl" {
  description = "TTL for DNS CNAME record (seconds)."
  type        = number
  default     = 300
}

variable "dns_subdomain" {
  description = "Subdomain for health assistant API."
  type        = string
  default     = "health"
}

variable "plugin_logo_url" {
  description = "Logo URL for ChatGPT Actions plugin manifest."
  type        = string
  default     = "https://via.placeholder.com/128.png?text=Health+Assistant"
}

variable "plugin_contact_email" {
  description = "Contact email for ChatGPT Actions plugin manifest."
  type        = string
  default     = "rbarrimond+health-assistant@users.noreply.github.com"
}

variable "plugin_legal_url" {
  description = "Legal info URL for ChatGPT Actions plugin manifest."
  type        = string
  default     = "https://github.com/rbarrimond/health_assistant/blob/main/README.md"
}
