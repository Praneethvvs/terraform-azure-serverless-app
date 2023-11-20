variable "resource_group_name" {
  description = "Name of the resource group that you want to create for container apps and its resources"
  type        = string
  default     = "ContainerApp-ResourceGroup"
}


variable "vnet_name" {
  description = "Name of the resource group that you want to create for container apps and its resources"
  type        = string
  default     = "VNET1-CONAPP-TEST"
}

variable "private_dns_zone_name" {
    description = "name of the private dns zone to resolve dns"
    type = string
    default = "eastus.azurecontainerapps.io"
  
}

variable "virtual_link_name" {
    description = "name of the virtual link between private dns zone and virtual network"
    type = string
    default = "container-app-link"
  
}

variable "container_app_env_name" {
    description = "name of the container app env for the container app application"
    type = string
    default = "container-app-env"
  
}


variable "container_app_frontend_name" {
    description = "name of the container app env for the container app application"
    type = string
    default = "container-app-frontend"
  
}

