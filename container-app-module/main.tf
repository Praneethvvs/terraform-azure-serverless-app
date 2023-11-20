terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.64.0"
    }
  }
}



data "azurerm_resource_group" "container-app-resource-group" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "VNET" {
  name                = var.vnet_name
  resource_group_name = data.azurerm_resource_group.container-app-resource-group.name
}

data "azurerm_subnet" "container_app_subnet" {
  name = var.container_app_resources_config.container_app_infrastructure_subnet_name
  virtual_network_name = data.azurerm_virtual_network.VNET.name
  resource_group_name  = data.azurerm_resource_group.container-app-resource-group.name

}

resource "azurerm_log_analytics_workspace" "container-app-logworkspace" {
  name                = var.container_app_resources_config.container_app_log_workspace_name
  location            = data.azurerm_resource_group.container-app-resource-group.location
  resource_group_name = data.azurerm_resource_group.container-app-resource-group.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "container-app-env" {
  name                       = var.container_app_resources_config.container_app_env_name
  location                   = data.azurerm_resource_group.container-app-resource-group.location
  resource_group_name        = data.azurerm_resource_group.container-app-resource-group.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.container-app-logworkspace.id
  infrastructure_subnet_id   = data.azurerm_subnet.container_app_subnet.id
  internal_load_balancer_enabled = true
}


resource "azurerm_container_app" "container-app-backend" {

  name                         = var.container_apps.backend_container_app_config.container_app_name
  container_app_environment_id = azurerm_container_app_environment.container-app-env.id
  resource_group_name          = data.azurerm_resource_group.container-app-resource-group.name
  revision_mode                = "Single"
  ingress {
    external_enabled = var.container_apps.backend_container_app_config.ingress_config.external_enabled
    target_port      = var.container_apps.backend_container_app_config.ingress_config.target_port
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {

    container {
      name   = var.container_apps.backend_container_app_config.container_template_config.container_name
      image  = var.container_apps.backend_container_app_config.container_template_config.image_name
      cpu    = var.container_apps.backend_container_app_config.container_template_config.cpu
      memory = var.container_apps.backend_container_app_config.container_template_config.memory
    }

  }

}


resource "azurerm_container_app" "container-app-frontend" {

  name                         = var.container_apps.frontend_container_app_config.container_app_name
  container_app_environment_id = azurerm_container_app_environment.container-app-env.id
  resource_group_name          = data.azurerm_resource_group.container-app-resource-group.name
  revision_mode                = "Single"
  ingress {
    external_enabled = var.container_apps.frontend_container_app_config.ingress_config.external_enabled
    target_port      = var.container_apps.frontend_container_app_config.ingress_config.target_port
    traffic_weight {
      percentage      = 100
      latest_revision = true
    }
  }

  template {

    container {
      name   = var.container_apps.frontend_container_app_config.container_template_config.container_name
      image  = var.container_apps.frontend_container_app_config.container_template_config.image_name
      cpu    = var.container_apps.frontend_container_app_config.container_template_config.cpu
      memory = var.container_apps.frontend_container_app_config.container_template_config.memory
      env {
        name  = "APP_URL"
        value = "https://${azurerm_container_app.container-app-backend.latest_revision_fqdn}"

      }
    }
  }

}

