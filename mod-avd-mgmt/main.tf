resource "azurerm_virtual_desktop_application_group" "core_application_group" {
  name                = "appg-${var.core_settings.host_pool_name}"
  location            = var.core_settings.location
  resource_group_name = var.core_settings.resource_group_name

  type          = "Desktop"
  host_pool_id  = var.core_settings.host_pool_id
  friendly_name = var.core_settings.naming.friendly_name
  description   = var.core_settings.naming.description

  tags = merge(
    var.core_settings.tags,
    {
      provisioned_with = "terraform"
      hidden-title     = var.core_settings.naming.friendly_name,
    }
  )
}

resource "azurerm_virtual_desktop_workspace" "core_workspace" {
  name                = "ws-${var.core_settings.host_pool_name}"
  location            = var.core_settings.location
  resource_group_name = var.core_settings.resource_group_name

  friendly_name = var.core_settings.naming.friendly_name
  description   = var.core_settings.naming.description
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "workspaceremoteapp" {
  workspace_id         = azurerm_virtual_desktop_workspace.core_workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.core_application_group.id
}

resource "azuread_group" "avd_user_group" {
  display_name     = "avd-users-${var.core_settings.host_pool_name}"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
}

resource "azurerm_role_assignment" "avd_users" {
  scope                = azurerm_virtual_desktop_application_group.core_application_group.id
  role_definition_name = "Desktop Virtualization User"
  principal_id         = azuread_group.avd_user_group.object_id
}

resource "azuread_group_member" "avd_user_group_members" {
  for_each         = data.azuread_user.users
  group_object_id  = azuread_group.avd_user_group.object_id
  member_object_id = each.value.object_id
}

resource "azuread_group_member" "logix_smb_group_members" {
  for_each         = data.azuread_user.users
  group_object_id  = var.application_group_settings.logix_smb_group_id
  member_object_id = each.value.object_id
}
