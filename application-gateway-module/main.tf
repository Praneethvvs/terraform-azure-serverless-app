
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.64.0"
    }
  }
}


#resource group
data "azurerm_resource_group" "container-app-resource-group" {
  name     = var.resource_group_name
}

data "azurerm_virtual_network" "VNET" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.container-app-resource-group.name
}

data "azurerm_subnet" "app_gw_subnet" {
  name = var.app_gateway_subnet_name
  virtual_network_name = data.azurerm_virtual_network.VNET.name
  resource_group_name  = data.azurerm_resource_group.container-app-resource-group.name

}
data "azurerm_container_app" "container_app_frontend" {
    name = var.container_app_frontend_name
    resource_group_name = data.azurerm_resource_group.container-app-resource-group.name
}


resource "azurerm_public_ip" "app-gw-public-ip" {
  name                = var.public_ip_settings.name
  resource_group_name = data.azurerm_resource_group.container-app-resource-group.name
  location            = data.azurerm_resource_group.container-app-resource-group.location
  allocation_method   = var.public_ip_settings.allocation_method
  sku = "Standard"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "${var.app_gateway_name}-beap"
  frontend_port_name             = "${var.app_gateway_name}-feport"
  frontend_ip_configuration_name = "${var.app_gateway_name}-feip"
  http_setting_name              = "${var.app_gateway_name}-be-htst"
  listener_name                  = "${var.app_gateway_name}-httplstn"
  request_routing_rule_name      = "${var.app_gateway_name}-rqrt"
  redirect_configuration_name    = "${var.app_gateway_name}-rdrcfg"
  probe_name =  "${var.app_gateway_name}-healthprobe"
}

resource "azurerm_application_gateway" "application_gateway" {
  name                = var.app_gateway_name
  resource_group_name = data.azurerm_resource_group.container-app-resource-group.name
  location            = data.azurerm_resource_group.container-app-resource-group.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    
  }

  autoscale_configuration {
    min_capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = data.azurerm_subnet.app_gw_subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.app-gw-public-ip.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
    fqdns = ["${data.azurerm_container_app.container_app_frontend.ingress[0].fqdn}"]
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 443
    protocol              = "Https"
    request_timeout       = 20
    pick_host_name_from_backend_address = true
    probe_name = local.probe_name
  }

  probe {
    name=local.probe_name
    protocol = "Https"
    path = "/"
    interval = 30
    timeout = 10
    pick_host_name_from_backend_http_settings = true
    unhealthy_threshold = 3


  }


  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
    priority = 100
  }
}