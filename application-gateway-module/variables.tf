variable "app_gateway_name" {
  type        = string
  description = "name of the application gateway"
  default = "app-gw-container-app"

}

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

variable "app_gateway_subnet_name" {
  description = "Details of the subnet where you want the application gateway in"
  type =string
  default =  "app-gw-subnet"
  
}

variable "container_app_frontend_name" {
    description = "name of the container app env for the container app application"
    type = string
    default = "container-app-frontend"
  
}

variable "public_ip_settings" {
  description = "settings for public ip of application gateway"
  type = object({
    name = string
    allocation_method = string
  })
  default = {
    name = "app-gw-public-ip"
    allocation_method = "Static"
  }
}
