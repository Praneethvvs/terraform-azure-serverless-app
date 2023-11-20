#----------------------------------ResourceGroup Variables-----------------------
variable "resource_group_name" {
  description = "Name of the resource group that you want to create for container apps and its resources"
  type        = string
  default     = "ContainerApp-ResourceGroup"
}



#------------------------------VNET VARIABLES------------------------------------
variable "vnet_details" {
  description = "Name of the VNET"
  type = object({
    name          = string
    address_space = list(string)
  })
  default = {
    name          = "VNET1-CONAPP-TEST"
    address_space = ["10.0.0.0/16"]
  }
}



variable "app_gateway_subnet_details" {
  description = "Details of the subnet where you want the application gateway in"
  type = object({
    subnet_name = string
    subnet_id   = list(string)
  })
  default = {
    subnet_name = "app-gw-subnet"
    subnet_id   = ["10.0.1.0/24"]
  }
}

variable "container_app_subnet_details" {
  description = "Details of the subnet where you want the container app in"
  type = object({
    subnet_name = string
    subnet_id   = list(string)
  })
  default = {
    subnet_name = "container-app-subnet"
    subnet_id   = ["10.0.2.0/23"]
  }
}


#------------------------------Container App Variables------------------------------------

variable "container_app_resources_config" {
  type = object({
    container_app_env_name                 = string
    container_app_log_workspace_name       = string
    container_app_infrastructure_subnet_name = string

  })
  default = {
    container_app_env_name                 = "container-app-env"
    container_app_log_workspace_name       = "container-app-log-workspace"
    container_app_infrastructure_subnet_name = "container-app-subnet"
  }
}

variable "container_apps" {
  type = object({

    frontend_container_app_config = object({
      container_app_name = string
      ingress_config = object({
        external_enabled = bool
        target_port      = number
      }),
      container_template_config = object({
        container_name = string
        image_name     = string
        cpu            = number
        memory         = string
      })

    }),

    backend_container_app_config = object({
      container_app_name = string
      ingress_config = object({
        external_enabled = bool
        target_port      = number
      }),
      container_template_config = object({
        container_name = string
        image_name     = string
        cpu            = number
        memory         = string
      })

    })

  })

  default = {
    backend_container_app_config = {
      container_app_name        = "container-app-backend"
      ingress_config            = { external_enabled = true, target_port = 8000 }
      container_template_config = { container_name = "calculator-app-backend", image_name = "docker.io/pvvsdoc001/calculator-flask-microservice-backend:v1", cpu = 0.25, memory = "0.5Gi" }

    },
    frontend_container_app_config = {
      container_app_name        = "container-app-frontend"
      ingress_config            = { external_enabled = true, target_port = 5000 }
      container_template_config = { container_name = "calculator-app-frontend", image_name = "docker.io/pvvsdoc001/calculator-flask-microservice-frontend:v3", cpu = 0.25, memory = "0.5Gi" }

    }

  }

}

