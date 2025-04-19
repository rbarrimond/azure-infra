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