module "regions" {
  source  = "Azure/regions/azurerm"
  version = "~> 0.3"
}
data "http" "public_ip" {
  url = "https://api.ipify.org?format=json"
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
    nsg-frontend = {
      id = "${local.name}-nsg-frontend"
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
        },
        {
          name                       = "AllowInternalTraffic"
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "10.0.0.0/16"  #Internal VNet range
          destination_address_prefix = "*"
        },
        {
          name                       = "DenyAllInbound"
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }   
      ]  
    }
    nsg-backend = {
      id = "${local.name}-nsg-backend"
      security_rules = [
        {
          name                       = "AllowFrontendToBackend"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "8080"
          source_address_prefix      = "10.0.1.0/24" #Frontend subnet IP range
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowInternalTraffic"
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "10.0.0.0/16"  #Internal VNet range
          destination_address_prefix = "*"
        },
        {
          name                       = "DenyAllInbound"
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }   
      ]  
    }
    nsg-database = {
      id = "${local.name}-nsg-database"
      security_rules = [
        {
          name                       = "AllowBackendToDatabase"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "1433" #SQL database port (any database)
          source_address_prefix      = "10.0.2.0/24" #Backend subnet IP range
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowInternalTraffic"
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "10.0.0.0/16"  #Internal VNet range
          destination_address_prefix = "*"
        },
        {
          name                       = "DenyAllInbound"
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }               
      ]  
    }
    nsg-dmz = {
      id = "${local.name}-nsg-dmz"
      security_rules = [
        {
          name                       = "AllowPublicToDMZ"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443" #Public facing APIs access
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowInternalTraffic"
          priority                   = 200
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "10.0.0.0/16"  #Internal VNet range
          destination_address_prefix = "*"
        },
        {
          name                       = "DenyAllInbound"
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }   
      ]  
    }                          
  }
  route_table = {
    route_table_frontend = {
      name = "frontend-route-table"
      location = local.location
      resource_group_name = "${local.name}-rsg"
      route = [
        {
          name = "internet-route"
          address_prefix = "0.0.0.0/0"
          next_hop_type = "Internet"
        },
        {
          name = "backend-route"
          address_prefix = "10.0.1.0/24"  
          next_hop_type = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.0.0" #backend IP
        }
      ]
    }
    route_table_backend = {
      name = "backend-route-table"
      location = local.location
      resource_group_name = "${local.name}-rsg"
      route = [
        {
          name                   = "frontend-route"
          address_prefix         = "10.0.2.0/24"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.0.0" # frontend IP
        },
        {
          name                   = "internet-route"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "Internet"
        }
      ]
    }
    route_table_database = {
      name = "database-route-table"
      location = local.location
      resource_group_name = "${local.name}-rsg"
      route = [
        {
          name                   = "backend-route"
          address_prefix         = "10.0.3.0/24"
          next_hop_type          = "VirtualAppliance"
          next_hop_in_ip_address = "10.0.0.0" # backend IP
        },
        {
          name                   = "internet-route"
          address_prefix         = "0.0.0.0/0"
          next_hop_type          = "Internet"
        }
      ]
    }        
  }
  subnets = {
    apps-frontend = {
      name = "${local.name}-apps-frontend-sn"
      address_prefixes = ["10.0.1.0/24"]
      network_security_group = { id = module.learn-terraform-vnet.network_security_groups["nsg-frontend"] }
      route_table = { id = module.learn-terraform-vnet.route_table["route_table_frontend" ]}
      delegations = null
      private_endpoint_network_policies = "Disabled"
      private_link_service_network_policies_enabled = "false"
      service_endpoints = null
    }
    apps-backend = {
      name = "${local.name}-apps-backend-sn"
      address_prefixes = ["10.0.2.0/24"]
      network_security_group = { id = module.learn-terraform-vnet.network_security_groups["nsg-backend"] }
      route_table = null
      delegations = null
      private_endpoint_network_policies = "Disabled"
      private_link_service_network_policies_enabled = "false"
      service_endpoints = null
    }
    apps-database = {
      name = "${local.name}-apps-database-sn"
      address_prefixes = ["10.0.3.0/24"]
      network_security_group = { id = module.learn-terraform-vnet.network_security_groups["nsg-database"] }
      route_table = null
      delegations = null
      private_endpoint_network_policies = "Disabled"
      private_link_service_network_policies_enabled = "false"
      service_endpoints = null
    }
    apps-dmz = {
      name = "${local.name}-apps-dmz-sn"
      address_prefixes = ["10.0.4.0/24"]
      network_security_group = { id = module.learn-terraform-vnet.network_security_groups["nsg-dmz"] }
      route_table = null
      delegations = null
      private_endpoint_network_policies = "Disabled"
      private_link_service_network_policies_enabled = "false"
      service_endpoints = null
    }            
  }
}

# output "resource_group_name" {
#   value = module.learn-terraform-vnet.resource_group_name
# }


# output "network_security_group" {
#   value = module.learn-terraform-vnet.network_security_groups["nsg1"]
# }

# output "route_table" {
#   value = module.learn-terraform-vnet.route_table["route_table_frontend"]
# }
