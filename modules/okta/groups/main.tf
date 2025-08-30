terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

resource "okta_group" "this" {
  name                      = var.name
  description               = var.description
  custom_profile_attributes = length(var.custom_profile_attributes) > 0 ? jsonencode(var.custom_profile_attributes) : null
}

resource "okta_group_role" "this" {
  for_each = {
    for role in var.role_assignments : role.admin_role => role
  }

  group_id              = okta_group.this.id
  role_type             = each.key
  target_app_list       = lookup(each.value, "target_apps", [])
  target_group_list     = lookup(each.value, "target_groups", [])
  disable_notifications = !var.role_notification_enabled
}

resource "okta_group_rule" "this" {
  for_each = {
    for rule in var.rules : rule.name => rule
  }

  name                  = each.value.name
  status                = each.value.enabled ? "ACTIVE" : "INACTIVE"
  remove_assigned_users = each.value.cascade_on_delete
  expression_type       = "urn:okta:expression:1.0"
  expression_value      = each.value.expression_value
  group_assignments     = [okta_group.this.id]
}
