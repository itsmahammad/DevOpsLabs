output "frontend_private_ip" {
  value = azurerm_network_interface.frontend.private_ip_address
}

output "backend_private_ip" {
  value = azurerm_network_interface.backend.private_ip_address
}

output "ops_private_ip" {
  value = azurerm_network_interface.ops.private_ip_address
}

output "ops_public_ip" {
  value = azurerm_public_ip.ops.ip_address
}

output "frontend_nic_id" {
  value = azurerm_network_interface.frontend.id
}

output "backend_nic_id" {
  value = azurerm_network_interface.backend.id
}
