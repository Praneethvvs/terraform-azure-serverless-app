terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.64.0"
    }
  }
}


data "azurerm_resource_group" "container-app-resource-group" {
  name     = var.resource_group_name
}

data "azurerm_virtual_network" "VNET" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.container-app-resource-group.name
}
resource "azurerm_private_dns_zone" "container-app-private-zone" {
  name                = var.private_dns_zone_name
  resource_group_name = data.azurerm_resource_group.container-app-resource-group.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "virtual-network-link" {
  name                  = var.virtual_link_name
  resource_group_name   = data.azurerm_resource_group.container-app-resource-group.name
  private_dns_zone_name = azurerm_private_dns_zone.container-app-private-zone.name
  virtual_network_id    = data.azurerm_virtual_network.VNET.id
}


data "azurerm_container_app_environment" "container-app-env" {
    name = var.container_app_env_name
    resource_group_name = data.azurerm_resource_group.container-app-resource-group.name
}

data "azurerm_container_app" "container_app_frontend" {
    name = var.container_app_frontend_name
    resource_group_name = data.azurerm_resource_group.container-app-resource-group.name
}


resource "azurerm_private_dns_a_record" "example" {
  # name                = data.azurerm_container_app.container_app_frontend.ingress[0].fqdn
  name = "*"
  zone_name           = azurerm_private_dns_zone.container-app-private-zone.name
  resource_group_name = data.azurerm_resource_group.container-app-resource-group.name
  ttl                 = 300
  records             = ["${data.azurerm_container_app_environment.container-app-env.static_ip_address}"]
}


