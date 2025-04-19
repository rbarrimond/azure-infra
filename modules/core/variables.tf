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