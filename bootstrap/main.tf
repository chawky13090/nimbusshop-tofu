# Crée UNIQUEMENT le compte de stockage qui contiendra le state du projet principal.
# À lancer une seule fois (son propre state reste local) : tofu init && tofu apply
terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
    random  = { source = "hashicorp/random", version = "~> 3.6" }
  }
}

variable "subscription_id" {
  description = "ID de l'abonnement Azure"
  type        = string
}

variable "location" {
  description = "Région Azure"
  type        = string
  default     = "spaincentral"
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

locals {
  tags = { projet = "nimbusshop", owner = "binome4", env = "exam" }
}

resource "random_string" "sfx" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "state" {
  name     = "rg-tfstate-nimbus-4"
  location = var.location
  tags     = local.tags
}

resource "azurerm_storage_account" "state" {
  name                     = "stnimbus4${random_string.sfx.result}"
  resource_group_name      = azurerm_resource_group.state.name
  location                 = azurerm_resource_group.state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

resource "azurerm_storage_container" "state" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
}

output "backend_hcl" {
  description = "Contenu à mettre dans ../backend.hcl"
  value       = <<-EOT
    resource_group_name  = "${azurerm_resource_group.state.name}"
    storage_account_name = "${azurerm_storage_account.state.name}"
    container_name       = "tfstate"
    key                  = "nimbus.tfstate"
  EOT
}
