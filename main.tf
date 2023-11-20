
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.64.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}


#-----CREATE RESOURCE GROUP----------
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "East US"
}


module "vnet" {
  source = ".//vnet-module"
  # source              = "Azure/vnet/azurerm"
  vnet_name               = var.vnet_details.name
  resource_group_name     = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location
  address_space           = var.vnet_details.address_space
  subnet_details_config_list = [{
    subnet_name   = var.app_gateway_subnet_details.subnet_name
    subnet_prefix = var.app_gateway_subnet_details.subnet_id
    },
    {
      subnet_name   = var.container_app_subnet_details.subnet_name
      subnet_prefix = var.container_app_subnet_details.subnet_id
    }
  ]
  depends_on = [azurerm_resource_group.rg]
}


module "container-app" {
  source = ".//container-app-module"

  resource_group_name     = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location

  container_app_resources_config = var.container_app_resources_config
  container_apps = var.container_apps
  depends_on = [azurerm_resource_group.rg, module.vnet]
}



module "private_dns_zone" {
  source = ".//private_dns_zone_module"

  depends_on = [azurerm_resource_group.rg, module.vnet, module.container-app]
}



module "application_gateway" {

  source = ".//application-gateway-module"

  depends_on = [azurerm_resource_group.rg, module.vnet, module.container-app, module.private_dns_zone]

}

