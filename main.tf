resource "azurerm_resource_group" "resource_group" {
  name     = "rg-${var.core_settings.naming.landing_zone}-${var.core_settings.naming.environment}-${var.core_settings.naming.workload_name}"
  location = var.core_settings.location

  tags = merge(
    var.core_settings.tags,
    {
      provisioned_with = "terraform"
      hidden-title     = var.core_settings.naming.friendly_name,
    }
  )
}

module "mod-avd-network" {
  source = "./mod-avd-network"
  core_settings = {
    naming = {
      friendly_name = var.core_settings.naming.friendly_name
    }

    host_pool_name      = module.mod-avd-compute.host_pool_name
    resource_group_name = azurerm_resource_group.resource_group.name
    location            = var.core_settings.location

    tags = var.core_settings.tags
  }

  subnet_settings                 = var.network_settings.subnet_settings
  network_security_group_settings = var.network_settings.network_security_group_settings

  depends_on = [azurerm_resource_group.resource_group]
}

module "mod-avd-compute" {
  source = "./mod-avd-compute"
  core_settings = {
    location            = var.core_settings.location
    resource_group_name = azurerm_resource_group.resource_group.name
    naming              = var.core_settings.naming
    timezone            = var.core_settings.timezone

    tags = var.core_settings.tags
  }

  host_pool_settings = {
    maximum_sessions_allowed = var.compute_settings.host_pool_settings.maximum_sessions_allowed

    scheduled_agent_updates = {
      timezone = var.core_settings.timezone
      schedule = {
        day_of_week = var.compute_settings.host_pool_settings.scheduled_agent_updates.day_of_week
        hour_of_day = var.compute_settings.host_pool_settings.scheduled_agent_updates.hour_of_day
      }
    }
  }

  virtual_machine_settings = merge(var.compute_settings.virtual_machine_settings, {
    subnet_id = module.mod-avd-network.host_pool_subnet_id
  })

  depends_on = [azurerm_resource_group.resource_group]
}

module "mod-avd-mgmt" {
  source = "./mod-avd-mgmt"
  core_settings = {
    naming = {
      friendly_name = var.core_settings.naming.friendly_name
      description   = var.core_settings.naming.description
    }

    host_pool_name      = module.mod-avd-compute.host_pool_name
    host_pool_id        = module.mod-avd-compute.host_pool_id
    resource_group_name = azurerm_resource_group.resource_group.name
    location            = var.core_settings.location

    tags = var.core_settings.tags
  }

  application_group_settings = var.mgmt_settings.application_group_settings


  depends_on = [azurerm_resource_group.resource_group]

}
