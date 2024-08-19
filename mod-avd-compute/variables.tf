variable "core_settings" {
  type = object({
    naming = object({
      landing_zone  = string
      environment   = string
      workload_name = string
      description   = string
      friendly_name = string
    })

    resource_group_name = string
    location            = string
    timezone            = string

    tags = map(string)
  })
}

variable "host_pool_settings" {
  type = object({
    maximum_sessions_allowed = number

    scheduled_agent_updates = object({
      schedule = object({
        day_of_week = string
        hour_of_day = number
      })
    })
  })
}

variable "virtual_machine_settings" {
  type = object({
    virtual_machine_count = number
    subnet_id             = string
    virtual_machine_size  = string
    os_disk_size_gb       = number

    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })

    key_vault_id_for_admin_passwords = string
  })
}


