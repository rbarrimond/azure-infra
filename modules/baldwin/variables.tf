variable "dns_rg" {
  description = "The name of the resource group containing the DNS zone."
  type        = string
}

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
