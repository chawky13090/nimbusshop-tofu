output "site_url" {
  description = "URL du site NimbusShop (via le Load Balancer)"
  value       = "http://${azurerm_public_ip.lb.ip_address}"
}

output "jumpbox_ip" {
  description = "IP publique de la jumpbox"
  value       = azurerm_public_ip.jump.ip_address
}

output "web_private_ips" {
  description = "IP privées des VM web (pour ssh -J)"
  value       = azurerm_network_interface.web[*].private_ip_address
}
