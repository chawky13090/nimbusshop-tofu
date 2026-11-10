# ---------- 2 VM web identiques (count = 2), sans IP publique ----------
resource "azurerm_network_interface" "web" {
  count               = 2
  name                = "nic-web${count.index + 1}-${local.suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    # Pas de public_ip_address_id : la VM n'est joignable que via le LB
  }
}

# Branche chaque carte réseau au pool du Load Balancer
resource "azurerm_network_interface_backend_address_pool_association" "web" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.web[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool.id
}

resource "azurerm_linux_virtual_machine" "web" {
  count                 = 2
  name                  = "vm-web${count.index + 1}-${local.suffix}"
  computer_name         = "vm-web${count.index + 1}" # nom d'hôte affiché sur la page
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.web[count.index].id]
  custom_data           = filebase64("${path.module}/cloud-init.yaml") # installe nginx
  tags                  = var.tags

  # Clé SSH uniquement, mot de passe désactivé
  disable_password_authentication = true
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  # L'accès sortant (apt) doit exister avant le démarrage de cloud-init
  depends_on = [azurerm_lb_outbound_rule.out]
}
