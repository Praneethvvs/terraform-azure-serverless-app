variable "vnet_name" {
  description = "Name of the vnet to create"
  type        = string
  default     = "VNET1-CONAPP-TEST"
}

variable "resource_group_name" {
  description = "Name of the resource group to be imported."
  type        = string
}

variable "resource_group_location" {
  description = "Name of the resource group to be imported."
  type        = string
}

variable "address_space" {
  type        = list(string)
  description = "The address space that is used by the virtual network."
  default     = ["10.0.0.0/16"]
}


variable "subnet_details_config_list" {
    type = set(object({
      subnet_name = string
      subnet_prefix = list(string)
    }))
}


# variable "subnet_prefixes" {
#   description = "The address prefix to use for the subnet."
#   type        = list(string)
#   default     = ["10.0.1.0/24"]
# }

# variable "subnet_names" {
#   description = "A list of public subnets inside the vNet."
#   type        = list(string)
#   default     = ["app-gw-subnet", "container-app-subnet"]
# }