#!/usr/bin/env bash
# Supprime TOUT (à lancer une fois le dernier niveau validé) : ./destroy.sh
set -euo pipefail
cd "$(dirname "$0")"
SUB=$(az account show --query id -o tsv)
tofu init -reconfigure -backend-config=backend.hcl -input=false
tofu destroy -auto-approve -input=false
( cd bootstrap && tofu destroy -auto-approve -input=false -var "subscription_id=$SUB" )
