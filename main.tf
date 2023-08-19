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

variable "env" {
  description = "The environment for the deployment"
  type        = string
  default = "dev"
}

locals {
  prefix               = "mmdemo-${var.env}"
  default_tags = {
    created-by  = "terraform"
    managed-by  = "terraform"
    environment = var.env
  }
}

# An example resource that does nothing.
resource "azurerm_resource_group" "rg" {
  location = "westeurope"
  name     = "${local.prefix}-rg"
  tags     = local.default_tags
}

resource "azurerm_service_plan" "asp" {
  name                = "${local.prefix}-asp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
  tags = local.default_tags
}

resource "azurerm_linux_web_app" "example" {

  name                = "mmdemo-weather-app"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id

  app_settings = {
    ASPNETCORE_ENVIRONMENT = var.env == "dev" ? "Development" : "Productions"
  }

  site_config {
    always_on = false
  }

  tags = local.default_tags
}