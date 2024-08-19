# resource "random_uuid" "example" {}

# resource "azurerm_role_definition" "example" {
#   name        = "AVD-AutoScale"
#   scope       = azurerm_resource_group.example.id
#   description = "AVD AutoScale Role"
#   permissions {
#     actions = [
#       "Microsoft.Insights/eventtypes/values/read",
#       "Microsoft.Compute/virtualMachines/deallocate/action",
#       "Microsoft.Compute/virtualMachines/restart/action",
#       "Microsoft.Compute/virtualMachines/powerOff/action",
#       "Microsoft.Compute/virtualMachines/start/action",
#       "Microsoft.Compute/virtualMachines/read",
#       "Microsoft.DesktopVirtualization/hostpools/read",
#       "Microsoft.DesktopVirtualization/hostpools/write",
#       "Microsoft.DesktopVirtualization/hostpools/sessionhosts/read",
#       "Microsoft.DesktopVirtualization/hostpools/sessionhosts/write",
#       "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/delete",
#       "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/read",
#       "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/sendMessage/action",
#       "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/read"
#     ]
#     not_actions = []
#   }
#   assignable_scopes = [
#     azurerm_resource_group.example.id,
#   ]
# }

# data "azuread_service_principal" "example" {
#   display_name = "Azure Virtual Desktop"
# }

# resource "azurerm_role_assignment" "example" {
#   name                             = random_uuid.example.result
#   scope                            = azurerm_resource_group.example.id
#   role_definition_id               = azurerm_role_definition.example.role_definition_resource_id
#   principal_id                     = data.azuread_service_principal.example.id
#   skip_service_principal_aad_check = true
# }

# resource "azurerm_virtual_desktop_scaling_plan" "example" {
#   name                = "example-scaling-plan"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
#   friendly_name       = "Scaling Plan Example"
#   description         = "Example Scaling Plan"
#   time_zone           = "GMT Standard Time"
#   schedule {
#     name                                 = "Weekdays"
#     days_of_week                         = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
#     ramp_up_start_time                   = "05:00"
#     ramp_up_load_balancing_algorithm     = "BreadthFirst"
#     ramp_up_minimum_hosts_percent        = 20
#     ramp_up_capacity_threshold_percent   = 10
#     peak_start_time                      = "09:00"
#     peak_load_balancing_algorithm        = "BreadthFirst"
#     ramp_down_start_time                 = "19:00"
#     ramp_down_load_balancing_algorithm   = "DepthFirst"
#     ramp_down_minimum_hosts_percent      = 10
#     ramp_down_force_logoff_users         = false
#     ramp_down_wait_time_minutes          = 45
#     ramp_down_notification_message       = "Please log off in the next 45 minutes..."
#     ramp_down_capacity_threshold_percent = 5
#     ramp_down_stop_hosts_when            = "ZeroSessions"
#     off_peak_start_time                  = "22:00"
#     off_peak_load_balancing_algorithm    = "DepthFirst"
#   }
#   host_pool {
#     hostpool_id          = azurerm_virtual_desktop_host_pool.example.id
#     scaling_plan_enabled = true
#   }
# }
