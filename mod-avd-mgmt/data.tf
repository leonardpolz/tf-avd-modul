data "azurerm_client_config" "current" {}

data "azuread_user" "users" {
  for_each            = { for mail in var.application_group_settings.avd_user_mails : mail => mail }
  user_principal_name = each.value
}
