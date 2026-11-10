# ---------- Load Balancer Standard ----------
resource "azurerm_public_ip" "lb" {
  name                = "pip-lb-${local.suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_lb" "lb" {
  name                = "lb-${local.suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "pool" {
  name            = "pool-web"
  loadbalancer_id = azurerm_lb.lb.id
}

# Sonde : le LB appelle GET /sante ; une VM qui ne répond pas "200" est retirée
resource "azurerm_lb_probe" "sante" {
  name                = "probe-sante"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Http"
  port                = 80
  request_path        = "/sante"
  interval_in_seconds = 5
  number_of_probes    = 2
}

# Règle : port 80 Internet -> port 80 des VM
resource "azurerm_lb_rule" "http" {
  name                           = "rule-http"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.pool.id]
  probe_id                       = azurerm_lb_probe.sante.id
  disable_outbound_snat          = true # la sortie est gérée par la règle ci-dessous
}

# Accès sortant explicite des VM web vers Internet
resource "azurerm_lb_outbound_rule" "out" {
  name                    = "outbound-web"
  loadbalancer_id         = azurerm_lb.lb.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool.id

  frontend_ip_configuration {
    name = "frontend"
  }
}
