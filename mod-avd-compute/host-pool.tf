resource "azurerm_virtual_desktop_host_pool" "host_pool" {
  location            = var.core_settings.location
  resource_group_name = var.core_settings.resource_group_name

  name                     = "avdhp-${var.core_settings.naming.landing_zone}-${var.core_settings.naming.environment}-${var.core_settings.naming.workload_name}"
  friendly_name            = var.core_settings.naming.friendly_name
  description              = var.core_settings.naming.description
  type                     = "Pooled"
  load_balancer_type       = "DepthFirst"
  validate_environment     = true
  start_vm_on_connect      = true
  custom_rdp_properties    = "audiocapturemode:i:1;audiomode:i:0;"
  maximum_sessions_allowed = var.host_pool_settings.maximum_sessions_allowed
  preferred_app_group_type = "Desktop"

  scheduled_agent_updates {
    enabled  = true
    timezone = var.core_settings.timezone

    schedule {
      day_of_week = var.host_pool_settings.scheduled_agent_updates.schedule.day_of_week
      hour_of_day = var.host_pool_settings.scheduled_agent_updates.schedule.hour_of_day
    }
  }

  tags = merge(
    var.core_settings.tags,
    {
      provisioned_with = "terraform"
      hidden-title     = var.core_settings.naming.friendly_name,
    }
  )
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "registration_info" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.host_pool.id
  expiration_date = timeadd(timestamp(), "10h")

  lifecycle {
    replace_triggered_by = [azurerm_windows_virtual_machine.virtual_machines]
    ignore_changes       = [expiration_date]
  }
}
