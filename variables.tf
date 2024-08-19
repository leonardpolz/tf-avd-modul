variable "core_settings" {
  type = object({
    naming = object({
      landing_zone  = string
      environment   = string
      workload_name = string
      friendly_name = string
      description   = string
    })

    location = optional(string, "westeurope")
    timezone = optional(string, "Central European Standard Time")

    tags = object({
      terraform_repository_url = string
    })
  })
}

variable "network_settings" {
  type = object({
    subnet_settings = object({
      virtual_network_resource_group_name = string
      virtual_network_name                = string
      address_range                       = string
    })

    network_security_group_settings = object({
      firewall_outbound_range = string
      firewall_inbound_ip     = string
    })
  })
}

variable "compute_settings" {
  type = object({

    host_pool_settings = optional(object({

      maximum_sessions_allowed = optional(number, 12)

      scheduled_agent_updates = optional(object({
        day_of_week = string
        hour_of_day = string
        }), {
        day_of_week = "Sunday"
        hour_of_day = 2
      }) }),
      {
        maximum_sessions_allowed = 12
        scheduled_agent_updates = {
          day_of_week = "Sunday"
          hour_of_day = 2
        }
      }
    )

    virtual_machine_settings = object({
      virtual_machine_count = optional(number, 2)
      virtual_machine_size  = optional(string, "Standard_D2as_v4")
      os_disk_size_gb       = optional(number, 128)

      source_image_reference = optional(object({
        publisher = string
        offer     = string
        sku       = string
        version   = string
        }), {
        publisher = "MicrosoftWindowsDesktop"
        offer     = "Windows-10"
        sku       = "win10-22h2-avd-g2"
        version   = "latest"
      })

      key_vault_id_for_admin_passwords = string
    })
  })
}

variable "mgmt_settings" {
  type = object({
    application_group_settings = object({
      avd_user_mails     = optional(list(string), [])
      logix_smb_group_id = string
    })
  })
}

