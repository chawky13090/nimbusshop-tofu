# NimbusShop – Infrastructure Azure avec OpenTofu (binôme 4)

Tout est créé par du code : `tofu apply` crée tout, `tofu destroy` supprime tout. Région : **spaincentral**, VM : **Standard_B2ats_v2**.

## Schéma en une phrase
Internet -> **Load Balancer** (port 80) -> 2 VM web nginx (sans IP publique).
Le SSH passe uniquement par la **jumpbox**, depuis votre IP.

## Fichiers (un fichier = un sujet)
| Fichier | Rôle |
|---|---|
| `versions.tf` | Versions d'OpenTofu, providers, provider Azure (connexion `az login`) |
| `variables.tf` | Toutes les valeurs personnelles (abonnement, IP, clé SSH, mail...) |
| `main.tf` | Resource Group, VNET `10.4.0.0/16`, subnets `10.4.1.0/24` et `10.4.2.0/24`, 2 NSG |
| `web.tf` | 2 VM web (`count = 2`), clé SSH uniquement, cloud-init |
| `cloud-init.yaml` | Installe nginx, page « NimbusShop » + nom d'hôte, page `/sante` = `OK-nimbus` |
| `lb.tf` | Load Balancer Standard, IP publique, pool, sonde `GET /sante`, règle 80, règle sortante |
| `admin.tf` | Niveau 2 : jumpbox |
| `monitoring.tf` | Niveau 3 : alerte CPU > 80 % pendant 5 min + mail |
| `secrets.tf` | Niveau 3 : `random_password` dans un Key Vault |
| `bootstrap/` | Niveau 2 : compte de stockage du state distant |

## Utilisation
En une commande : `az login` puis `./deploy.sh` (et `./destroy.sh` à la fin). Détail des étapes :
```bash
az login
# 1. state distant (une seule fois)
cd bootstrap && tofu init && tofu apply -var subscription_id=<ID> && cd ..
# 2. copier terraform.tfvars.example -> terraform.tfvars et remplir ; remplir backend.hcl avec l'output
tofu init -backend-config=backend.hcl
tofu fmt && tofu validate
tofu apply
```
Test : `curl $(tofu output -raw site_url)` plusieurs fois -> le nom d'hôte alterne.
SSH : `ssh -J azureuser@<jumpbox_ip> azureuser@<ip privée web>`.
Fin : `tofu destroy` (puis `cd bootstrap && tofu destroy`).

## Sécurité
Aucun secret dans le dépôt (`.gitignore` exclut state, `terraform.tfvars`, `backend.hcl`). Le mot de passe est généré puis stocké dans le Key Vault, jamais affiché.
