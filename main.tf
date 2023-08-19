terraform {
  backend "azurerm" {
    storage_account_name = "mmdemoterraform"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}

# An example resource that does nothing.
resource "null_resource" "example" {
    triggers = {
    value = "A example resource that does nothing!"
    }
}