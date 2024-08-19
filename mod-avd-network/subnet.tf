resource "azurerm_subnet" "host_pool_subnet" {
  name                              = var.core_settings.host_pool_name
  resource_group_name               = var.subnet_settings.virtual_network_resource_group_name
  virtual_network_name              = var.subnet_settings.virtual_network_name
  address_prefixes                  = [var.subnet_settings.address_range]
  private_endpoint_network_policies = "Disabled"
}
