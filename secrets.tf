# ---------- Niveau 3 : mot de passe aléatoire dans un Key Vault ----------
resource "random_password" "admin" {
  length  = 24
  special = true
}

resource "azurerm_key_vault" "kv" {
  name                = "kv-${local.suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = var.tags

  # Seul l'utilisateur connecté (az login) peut gérer les secrets
  access_policy {
    tenant_id          = data.azurerm_client_config.current.tenant_id
    object_id          = data.azurerm_client_config.current.object_id
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
  }
}

resource "azurerm_key_vault_secret" "admin_password" {
  name         = "admin-password"
  value        = random_password.admin.result # jamais affiché, ni dans le code ni dans les outputs
  key_vault_id = azurerm_key_vault.kv.id
}
