terraform {
  required_version = ">= 1.9.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  cloud {
    organization = "ra-devops-org"
    workspaces {
      name = "learn-terraform-azure"
      tags = ["learn-terraform"]
    }
  }
}

provider "azurerm" {
  features {

  }
}

