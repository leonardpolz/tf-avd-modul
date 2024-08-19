# resource "azurerm_network_security_group" "host_pool_subnet_nsg" {
#   name                = azurerm_subnet.host_pool_subnet.name
#   location            = var.core_settings.location
#   resource_group_name = var.core_settings.resource_group_name

#   tags = merge(
#     var.core_settings.tags,
#     {
#       provisioned_with = "terraform"
#       hidden-title     = var.core_settings.naming.friendly_name,
#     }
#   )

#   depends_on = [azurerm_subnet.host_pool_subnet]
# }

# resource "azurerm_subnet_network_security_group_association" "nsg_association" {
#   subnet_id                 = azurerm_subnet.host_pool_subnet.id
#   network_security_group_id = azurerm_network_security_group.host_pool_subnet_nsg.id
# }

# resource "azurerm_network_security_rule" "allow_inbound_from_fw" {
#   name                        = "allow_inbound_traffic_from_fw"
#   priority                    = 100
#   direction                   = "Inbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = azurerm_subnet.host_pool_subnet.address_prefixes[0]
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_network_security_group.host_pool_subnet_nsg.resource_group_name
#   network_security_group_name = azurerm_network_security_group.host_pool_subnet_nsg.name

#   depends_on = [azurerm_network_security_group.host_pool_subnet_nsg]
# }

# resource "azurerm_network_security_rule" "allow_outbound_to_fw" {
#   name                        = "allow_outbound_traffic_to_fw"
#   priority                    = 110
#   direction                   = "Outbound"
#   access                      = "Allow"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = azurerm_subnet.host_pool_subnet.address_prefixes[0]
#   destination_address_prefix  = var.network_security_group_settings.firewall_inbound_ip
#   resource_group_name         = azurerm_network_security_group.host_pool_subnet_nsg.resource_group_name
#   network_security_group_name = azurerm_network_security_group.host_pool_subnet_nsg.name

#   depends_on = [azurerm_network_security_group.host_pool_subnet_nsg]
# }

# resource "azurerm_network_security_rule" "deny_intra_subnet" {
#   name                        = "deny_intra_subnet"
#   priority                    = 1000
#   direction                   = "Outbound"
#   access                      = "Deny"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_network_security_group.host_pool_subnet_nsg.resource_group_name
#   network_security_group_name = azurerm_network_security_group.host_pool_subnet_nsg.name

#   depends_on = [azurerm_network_security_group.host_pool_subnet_nsg]
# }
