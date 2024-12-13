
resource "azurerm_resource_group" "resource_group_name" {
  location = var.location
  name     = var.resource_group_name
  tags = var.tags
}

module "vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  resource_group_name = azurerm_resource_group.resource_group_name.name
  location            = azurerm_resource_group.resource_group_name.location
  name                = var.vnet_full_name
  address_space       = var.vnet_address_spaces
  enable_telemetry    = false
  tags = azurerm_resource_group.resource_group_name.tags
}