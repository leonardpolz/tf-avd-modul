variable "core_settings" {
  type = object({
    naming = object({
      friendly_name = string
    })

    host_pool_name      = string
    resource_group_name = string
    location            = string

    tags = map(string)
  })
}

variable "subnet_settings" {
  type = object({
    virtual_network_resource_group_name = string
    virtual_network_name                = string
    address_range                       = string
  })
}

variable "network_security_group_settings" {
  type = object({
    firewall_outbound_range = string
    firewall_inbound_ip     = string
  })
}
