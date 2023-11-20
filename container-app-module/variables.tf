variable "resource_group_name" {
  type        = string
  description = "name of the resource group where we need to create the resources in"

}

variable "resource_group_location" {
  type        = string
  description = "location where we need to create the resources in"
}

variable "vnet_name" {
  description = "Name of the vnet"
  type        = string
  default     = "VNET1-CONAPP-TEST"
}


variable "container_app_resources_config" {
  type = object({
    container_app_env_name           = string
    container_app_log_workspace_name = string
    container_app_infrastructure_subnet_name = string
  })
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

}

