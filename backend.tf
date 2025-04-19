terraform {
  backend "azurerm" {
    resource_group_name  = "base"
    storage_account_name = "sabarrimond01"
    container_name       = "terraform"
    key                  = "terraform.tfstate"
  }
}
