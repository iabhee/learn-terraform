
resource "azurerm_resource_group" "resource_group_name" {
  location = var.location
  name     = var.resource_group_name
  tags     = var.tags
}

data "http" "public_ip" {
  url = "https://api.ipify.org?format=json"
}
output "resource_group_name" {
  value = azurerm_resource_group.resource_group_name.name
}
resource "azurerm_network_security_group" "nsg" {
  # for_each = { for nsg in var.network_security_group : nsg.id => nsg}
  for_each = var.network_security_group
  name = each.key
  # name                = each.value.id
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  depends_on = [ azurerm_resource_group.resource_group_name ]
  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }    
  }
  
}

output "network_security_groups" {
  value = { for k, v in azurerm_network_security_group.nsg : k => v.id }
}

resource "azurerm_route_table" "route_table" {
  location            = azurerm_resource_group.resource_group_name.location
  for_each =           var.route_table
  name = each.key
  resource_group_name = azurerm_resource_group.resource_group_name.name
  dynamic route {
    for_each =  each.value.route
    content {
      name = route.value.name
      address_prefix = route.value.address_prefix
      next_hop_type = route.value.next_hop_type
      next_hop_in_ip_address = route.value.next_hop_in_ip_address      
    }
  }
}

output "route_table" {
  value = { for k, v in azurerm_route_table.route_table : k => v.id }
}

module "vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  resource_group_name = azurerm_resource_group.resource_group_name.name
  location            = azurerm_resource_group.resource_group_name.location
  name                = var.vnet_full_name
  address_space       = var.vnet_address_spaces
  enable_telemetry    = false
  tags                = azurerm_resource_group.resource_group_name.tags
  subnets = length(var.subnets) > 0 ? var.subnets : null
  depends_on = [ 
    azurerm_network_security_group.nsg,
    azurerm_resource_group.resource_group_name
  ]  
}


