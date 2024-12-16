module "regions" {
  source  = "Azure/regions/azurerm"
  version = "~> 0.3"
}
data "http" "public_ip" {
  url = "https://api.ipify.org?format=json"
}

data "azurerm_network_security_group" "nsg" {
  name = "${local.name}-nsg"
  resource_group_name = "${local.name}-rsg"
}

module "learn-terraform-vnet" {
  source              = "../modules/vnet"
  resource_group_name = "${local.name}-rsg"
  location            = local.location
  vnet_full_name      = "${local.name}-vnet"
  vnet_address_spaces = ["10.0.0.0/16"]
  tags = {
    "Environment" = "Terraform Getting Started"
    "Team"        = "DevOps"
  }
  network_security_group = {
    nsg1 = {
      id = "${local.name}-nsg"
      security_rules = [
        {
          name                       = "AllowInboundHTTPS"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = jsondecode(data.http.public_ip.response_body).ip
          destination_address_prefix = "*"
        }
      ]  
    }        
  }
  subnets = {
    apps = {
      name = "${local.name}-sn"
      address_prefixes = ["10.0.0.0/24"]
      network_security_group = { id = data.azurerm_network_security_group.nsg.id }
      route_table = null
      delegations = null
      private_endpoint_network_policies = "Disabled"
      private_link_service_network_policies_enabled = "false"
      service_endpoints = null
    }
  }
}

