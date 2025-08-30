terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

resource "okta_user" "this" {
  for_each = { for u in var.users : u.email => u }
  # Identity
  login            = lookup(each.value, "username", each.value.email)
  first_name       = title(regex("^([^.]+)", each.value.email)[0])
  last_name        = title(regex("^[^.]+\\.([^.@]+)", each.value.email)[0])
  middle_name      = lookup(each.value, "middle_name", null)
  honorific_prefix = lookup(each.value, "honorific_prefix", null)
  honorific_suffix = lookup(each.value, "honorific_suffix", null)
  nick_name        = lookup(each.value, "nick_name", null)
  display_name     = lookup(each.value, "display_name", null)
  status           = lookup(each.value, "status", null)

  ## Contacts
  email         = each.value.email
  second_email  = lookup(each.value, "second_email", null)
  mobile_phone  = lookup(each.value, "mobile_phone", null)
  primary_phone = lookup(each.value, "primary_phone", null)
  profile_url   = lookup(each.value, "profile_url", null)

  ## Address
  street_address = lookup(each.value, "street_address", null)
  postal_address = lookup(each.value, "postal_address", null)
  city           = lookup(each.value, "city", null)
  state          = lookup(each.value, "state", null)
  zip_code       = lookup(each.value, "zip_code", null)
  country_code   = lookup(each.value, "country_code", null)

  ## Organizational Information
  organization    = lookup(each.value, "organization", null)
  division        = lookup(each.value, "division", null)
  department      = lookup(each.value, "department", null)
  cost_center     = lookup(each.value, "cost_center", null)
  title           = lookup(each.value, "title", null)
  user_type       = lookup(each.value, "user_type", null)
  employee_number = lookup(each.value, "employee_number", null)
  manager         = lookup(each.value, "manager", null)
  manager_id      = lookup(each.value, "manager_id", null)

  ## Preferences
  locale             = lookup(each.value, "locale", null)
  timezone           = lookup(each.value, "timezone", null)
  preferred_language = lookup(each.value, "preferred_language", null)
}
