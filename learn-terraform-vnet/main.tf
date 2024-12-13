module "regions" {
  source  = "Azure/regions/azurerm"
  version = "~> 0.3"
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
}

