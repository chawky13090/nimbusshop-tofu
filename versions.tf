# Versions d'OpenTofu et des "providers" (plugins) utilisés.
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # State distant dans le compte de stockage créé par ./bootstrap (niveau 2).
  # Les valeurs sont données à l'init : tofu init -backend-config=backend.hcl
  backend "azurerm" {}
}

provider "azurerm" {
  subscription_id = var.subscription_id # connexion via "az login", aucun secret ici

  # Providers Azure à enregistrer automatiquement (nécessaire pour les alertes)
  resource_providers_to_register = ["Microsoft.Insights"]

  features {
    key_vault {
      # Permet de recréer un Key Vault du même nom après un destroy
      purge_soft_delete_on_destroy = true
    }
  }
}
