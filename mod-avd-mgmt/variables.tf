variable "core_settings" {
  type = object({
    naming = object({
      friendly_name = string
      description   = string
    })

    host_pool_name      = string
    host_pool_id        = string
    resource_group_name = string
    location            = string

    tags = map(string)
  })
}

variable "application_group_settings" {
  type = object({
    avd_user_mails     = list(string)
    logix_smb_group_id = string
  })
}
