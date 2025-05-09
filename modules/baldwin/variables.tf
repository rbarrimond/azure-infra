variable "resource_group_name" {
  description = "The name of the resource group where resources will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
}

variable "zone_name" {
  description = "The DNS zone name to be used for the records."
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

variable "repository_url" {
  description = "The URL of the GitHub repository for the static web app."
  type        = string
}
variable "repository_branch" {
  description = "The branch of the GitHub repository to be used for the static web app."
  type        = string
  default     = "main"
}

variable "repository_token" {
  description = "The GitHub token for accessing the repository."
  type        = string
  sensitive   = true
}
