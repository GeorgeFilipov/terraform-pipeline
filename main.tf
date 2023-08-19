terraform {
  required_version = ">= 1.3"
  backend "azurerm" {
    resource_group_name  = "demo-shared"
    storage_account_name = "mmdemoterraform"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~>3.57.0"
    }
  }
}
# Configure the Azure provider
provider "azurerm" { 
  features {}  
}

# An example resource that does nothing.
resource "null_resource" "example" {
    triggers = {
    value = "A example resource that does nothing!"
    }
}