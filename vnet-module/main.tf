terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.64.0"
    }
  }
}

data "azurerm_resource_group" "vnet-resource-group" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.vnet-resource-group.name
  location            = data.azurerm_resource_group.vnet-resource-group.location
  address_space       = var.address_space
}

resource "azurerm_subnet" "subnet" {

  for_each = { for subnet_details in var.subnet_details_config_list :
  subnet_details.subnet_name => subnet_details }

  name                 = each.value.subnet_name
  resource_group_name  = data.azurerm_resource_group.vnet-resource-group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.subnet_prefix
}


