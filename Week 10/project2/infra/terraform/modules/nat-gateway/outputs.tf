output "nat_public_ip" {
  value = azurerm_public_ip.nat.ip_address
}
