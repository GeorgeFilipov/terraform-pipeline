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
}

locals {
  prefix               = "mmdemo-${var.env}"
  default_tags = {
    created-by  = "terraform"
    managed-by  = "terraform"
    environment = var.env
  }
}

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

resource "azurerm_linux_web_app" "weather_api" {

  name                = "mmdemo-weather-api"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.asp.location
  service_plan_id     = azurerm_service_plan.asp.id

  app_settings = {
    ASPNETCORE_ENVIRONMENT = var.env == "dev" ? "Development" : "Productions"
  }

  site_config {
    always_on = false
    application_stack {
      dotnet_version = "7.0"
    }
  }

  tags = local.default_tags
}

resource "random_password" "sqluser" {
  length  = 16
  special = false
  lifecycle {
    ignore_changes = all
  }
}

resource "random_password" "sqlpassword" {
  length           = 16
  special          = true
  override_special = "_%@"
  lifecycle {
    ignore_changes = all
  }
}

resource "azurerm_mssql_server" "sql_srv" {
  name                         = "${local.prefix}-srv"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = random_password.sqluser.result
  administrator_login_password = random_password.sqlpassword.result
}

resource "azurerm_mssql_database" "sql-db" {
  name           = "${local.prefix}-db"
  server_id      = azurerm_mssql_server.sql_srv.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  sku_name       = "Basic"
  zone_redundant = false

  tags = local.default_tags
}