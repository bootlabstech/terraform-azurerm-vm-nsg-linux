output "private_ip_addresses" {
  value = azurerm_network_interface.network_interface.private_ip_address
}