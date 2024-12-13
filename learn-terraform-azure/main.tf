terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  required_version = ">= 1.1.0"
  cloud {
    organization = "ra-devops-org"
    workspaces {
      name = "learn-terraform-azure"
    }
  }
}

provider "azurerm" {
  features {
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = "south central us"

  tags = {
    "Environment" = "Terraform Getting Started"
    "Team"        = "DevOps"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "myTFVnet"
  address_space       = ["10.0.0.0/16"]
  location            = "southcentralus"
  resource_group_name = azurerm_resource_group.rg.name
}