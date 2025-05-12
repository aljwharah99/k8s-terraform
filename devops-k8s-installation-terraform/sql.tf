resource "azurerm_mssql_server" "sql_server" {
  name                         = var.database_server_name
  resource_group_name          = azurerm_resource_group.resource_group.name
  location                     = azurerm_resource_group.resource_group.location
  version                      = "12.0"
  administrator_login          = var.administrator_login
  administrator_login_password = var.administrator_login_password
}

resource "azurerm_mssql_database" "sql_database" {
  name      = var.db_name
  server_id = azurerm_mssql_server.sql_server.id
  sku_name  = "S0"
}

resource "azurerm_private_endpoint" "private_endpoint" {
  name                = "${var.database_server_name}-pe"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  subnet_id           = azurerm_subnet.subnets.id

  private_service_connection {
    name                           = "${var.database_server_name}-psc"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }
}

resource "azurerm_private_dns_zone" "sql_dns" {
  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.resource_group.name
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                  = "${var.dns_zone_name}-link"
  resource_group_name   = azurerm_resource_group.resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = true
}

resource "azurerm_private_dns_a_record" "sql_dns_record" {
  name                = var.database_server_name
  zone_name           = azurerm_private_dns_zone.sql_dns.name
  resource_group_name = azurerm_resource_group.resource_group.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.private_endpoint.private_service_connection[0].private_ip_address]
}
