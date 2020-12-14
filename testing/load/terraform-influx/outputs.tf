output "influxdb_ip_address" {
  value = azurerm_public_ip.influxdb_pip.ip_address
}