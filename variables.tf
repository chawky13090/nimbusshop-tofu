variable "subscription_id" {
  description = "ID de l'abonnement Azure for Students utilisé pour le déploiement"
  type        = string
}

variable "location" {
  description = "Région Azure retenue lors du TP"
  type        = string
  default     = "spaincentral"
}

variable "vm_size" {
  description = "Taille des VM retenue lors du TP"
  type        = string
  default     = "Standard_B2ats_v2"
}

variable "binome" {
  description = "Numéro du binôme, utilisé dans le nom de toutes les ressources"
  type        = string
  default     = "4"
}

variable "numgroupe" {
  description = "Numéro de groupe : le VNET est 10.<numgroupe>.0.0/16"
  type        = number
  default     = 4
}

variable "admin_ip" {
  description = "Votre IP publique (sans /32) autorisée à se connecter en SSH à la jumpbox"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Chemin du fichier de clé SSH publique (.pub) installée sur les VM"
  type        = string
}

variable "alert_email" {
  description = "Adresse mail qui reçoit l'alerte CPU"
  type        = string
}

variable "admin_username" {
  description = "Nom de l'utilisateur Linux sur les VM"
  type        = string
  default     = "azureuser"
}

variable "tags" {
  description = "Tags appliqués à toutes les ressources (projet, owner, env)"
  type        = map(string)
  default = {
    projet = "nimbusshop"
    owner  = "binome4"
    env    = "exam"
  }
}
