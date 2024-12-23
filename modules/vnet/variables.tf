variable "vnet_full_name" {
  type        = string
  description = <<DESCRIPTION
  (Optionl) The name of the vnet to create.
  DESCRIPTION
  nullable    = false
}

variable "location" {
  type = string
}

variable "tags" {
  type = map(any)
}

variable "resource_group_name" {
  type = string
}

variable "vnet_address_spaces" {
  type = list(string)
}

variable "subnets" {
  description = "Option subnets to create within the virtual network"
  type = map(object({
    name             = string
    address_prefixes = list(string)
    network_security_group = object({
      id = string
    })
    route_table       = optional(object({ id = string }))
    service_endpoints = optional(list(string))
    delegations = optional(list(object({
      name = string
      serv_delegation = object({
        name    = string
        actions = list(string)
      })
    })))
    private_endpoint_network_policies             = optional(string)
    private_link_service_network_policies_enabled = optional(string)
  }))
  default = {}
}

variable "network_security_group" {
  type = map(object({
    id = string
    security_rules = list(object({
      name                       = string
      access                     = string
      destination_address_prefix = string
      destination_port_range     = string
      direction                  = string
      priority                   = number
      protocol                   = string
      source_address_prefix      = string
      source_port_range          = string
    }))
  }))
  default     = {}
  description = "List of Network Security Groups with security rules"
}

variable "route_table" {
  type = map(object({
    route = list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    }))
  }))
  description = "A map of route tables with routes."
}