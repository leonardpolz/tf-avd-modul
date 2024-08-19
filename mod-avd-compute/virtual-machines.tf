locals {
  vm_names = [
    for i in range(var.virtual_machine_settings.virtual_machine_count) : "vm-${azurerm_virtual_desktop_host_pool.host_pool.name}-${i}"
  ]
}

resource "azurerm_network_interface" "vm_network_interfaces" {
  count               = var.virtual_machine_settings.virtual_machine_count
  name                = "nic-${local.vm_names[count.index]}"
  location            = var.core_settings.location
  resource_group_name = var.core_settings.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.virtual_machine_settings.subnet_id
    private_ip_address_version    = "IPv4"
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(
    var.core_settings.tags,
    {
      provisioned_with = "terraform"
      hidden-title     = var.core_settings.naming.friendly_name,
    }
  )
}

resource "random_password" "vm_passwords" {
  count   = var.virtual_machine_settings.virtual_machine_count
  length  = 16
  special = true
}

resource "random_string" "random_id" {
  length  = 8
  special = false
  upper   = true
  lower   = false
}

resource "azurerm_windows_virtual_machine" "virtual_machines" {
  count                                                  = var.virtual_machine_settings.virtual_machine_count
  admin_username                                         = "adminuser"
  admin_password                                         = random_password.vm_passwords[count.index].result
  location                                               = var.core_settings.location
  name                                                   = local.vm_names[count.index]
  computer_name                                          = "${random_string.random_id.result}${count.index}"
  network_interface_ids                                  = [azurerm_network_interface.vm_network_interfaces[count.index].id]
  resource_group_name                                    = var.core_settings.resource_group_name
  size                                                   = var.virtual_machine_settings.virtual_machine_size
  allow_extension_operations                             = true
  bypass_platform_safety_checks_on_user_schedule_enabled = false
  enable_automatic_updates                               = true
  extensions_time_budget                                 = "PT1H30M"
  hotpatching_enabled                                    = false
  license_type                                           = "None"
  secure_boot_enabled                                    = true
  timezone                                               = var.core_settings.timezone

  os_disk {
    name                 = "${local.vm_names[count.index]}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.virtual_machine_settings.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.virtual_machine_settings.source_image_reference.publisher
    offer     = var.virtual_machine_settings.source_image_reference.offer
    sku       = var.virtual_machine_settings.source_image_reference.sku
    version   = var.virtual_machine_settings.source_image_reference.version
  }

  termination_notification {
    enabled = true
  }

  tags = merge(
    var.core_settings.tags,
    {
      provisioned_with = "terraform"
      hidden-title     = var.core_settings.naming.friendly_name,
    }
  )

  lifecycle {
    ignore_changes = [admin_password]
  }
}

resource "azurerm_key_vault_secret" "admin_passwords" {
  count        = var.virtual_machine_settings.virtual_machine_count
  name         = "${local.vm_names[count.index]}----adminuser"
  value        = random_password.vm_passwords[count.index].result
  key_vault_id = var.virtual_machine_settings.key_vault_id_for_admin_passwords

  lifecycle {
    ignore_changes = [value]
  }

  tags = merge(
    var.core_settings.tags,
    {
      provisioned_with = "terraform"
      hidden-title     = var.core_settings.naming.friendly_name,
    }
  )
}

resource "azurerm_virtual_machine_extension" "domain_join" {
  count                      = var.virtual_machine_settings.virtual_machine_count
  name                       = "domain-join"
  virtual_machine_id         = azurerm_windows_virtual_machine.virtual_machines.*.id[count.index]
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "Name": "testingtenant.de",
      "OUPath": "",
      "User": "eidadds@testingtenant.de",
      "Restart": "true",
      "Options": "3"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
      "Password": "geheim1234!"
    }
PROTECTED_SETTINGS

  lifecycle {
    ignore_changes = [settings, protected_settings]
  }
}

resource "azurerm_virtual_machine_extension" "host_pool_join" {
  count                      = var.virtual_machine_settings.virtual_machine_count
  name                       = "host-pool-join"
  virtual_machine_id         = azurerm_windows_virtual_machine.virtual_machines.*.id[count.index]
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = <<-SETTINGS
    {
      "modulesUrl": "https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip",
      "configurationFunction": "Configuration.ps1\\AddSessionHost",
      "properties": {
        "HostPoolName":"${azurerm_virtual_desktop_host_pool.host_pool.name}"
      }
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
  {
    "properties": {
      "registrationInfoToken": "${azurerm_virtual_desktop_host_pool_registration_info.registration_info.token}"
    }
  }
PROTECTED_SETTINGS

  depends_on = [
    azurerm_virtual_machine_extension.domain_join
  ]
}

# resource "azurerm_virtual_machine_extension" "postdeployment" {
#   count                      = var.virtual_machine_settings.virtual_machine_count
#   name                       = "postdeployment"
#   virtual_machine_id         = azurerm_windows_virtual_machine.virtual_machines.*.id[count.index]
#   publisher                  = "Microsoft.Compute"
#   type                       = "CustomScriptExtension"
#   type_handler_version       = "1.9"
#   auto_upgrade_minor_version = true

#   settings = <<SETTINGS
#     {
#       "fileUris": ["https://${var.postdeployment_storage_account_name}.blob.core.windows.net/${var.postdeployment_container_name}/${var.postdeployment_script_name}${var.postdeployment_container_sas}"],
#       "commandToExecute": "powershell -ExecutionPolicy Unrestricted -File ${var.postdeployment_script_name}"
#     }
# SETTINGS

#   depends_on = [
#     azurerm_virtual_machine_extension.domain_join,
#     azurerm_virtual_machine_extension.dsc
#   ]
# }
