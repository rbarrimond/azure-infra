
variable "custom_tags" {
  type = map(string)
  default = {}
}

locals {
  merged_tags = merge(local.default_tags, var.custom_tags)
}
