#!/usr/bin/env bash
# Déploie TOUT en une commande : ./deploy.sh
# Prérequis : az login déjà fait, terraform.tfvars rempli (voir terraform.tfvars.example).
set -euo pipefail
cd "$(dirname "$0")"

SUB=$(az account show --query id -o tsv)   # abonnement courant de az login

echo "==> 1/3 State distant (compte de stockage)"
( cd bootstrap
  tofu init -input=false
  tofu apply -auto-approve -input=false -var "subscription_id=$SUB"
  tofu output -raw backend_hcl > ../backend.hcl )

echo "==> 2/3 Initialisation et contrôle du code"
tofu init -reconfigure -backend-config=backend.hcl -input=false
tofu fmt -check -recursive
tofu validate

echo "==> 3/3 Création de l'infrastructure"
tofu apply -auto-approve -input=false

echo "Site : $(tofu output -raw site_url)"
