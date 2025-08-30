terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

###################################################
# Okta Global Session Policy
###################################################

resource "okta_policy_signon" "this" {
  name        = var.name
  description = var.description
  status      = var.enabled ? "ACTIVE" : "INACTIVE"

  priority        = var.priority
  groups_included = [data.okta_group.this.id]
}

data "okta_group" "this" {
  name = "Everyone"
}

###################################################
# Rules of Okta Global Session Policy
###################################################

resource "okta_policy_rule_signon" "this" {
  for_each = {
    for rule in var.rules :
    rule.name => rule
  }

  policy_id = okta_policy_signon.this.id

  name     = each.key
  priority = each.value.priority
  status   = each.value.enabled ? "ACTIVE" : "INACTIVE"


  ### Conditions
  users_excluded = each.value.condition.excluded_users

  network_connection = anytrue([
    length(each.value.condition.network.excluded_zones) > 0,
    length(each.value.condition.network.included_zones) > 0,
  ]) ? "ZONE" : "ANYWHERE"
  network_excludes = (length(each.value.condition.network.excluded_zones) > 0
    ? each.value.condition.network.excluded_zones
    : null
  )
  network_includes = (length(each.value.condition.network.included_zones) > 0
    ? each.value.condition.network.included_zones
    : null
  )

  authtype          = each.value.condition.authentication.entrypoint
  identity_provider = each.value.condition.authentication.identity_provider

  ### Effects
  access = each.value.allow_access ? "ALLOW" : "DENY"

  primary_factor = each.value.primary_factor

  mfa_required = each.value.mfa.required
  mfa_prompt   = each.value.mfa.prompt_mode
  mfa_lifetime = (each.value.mfa.required && each.value.mfa.prompt_mode == "SESSION"
    ? each.value.mfa.session_duration
    : 0
  )
  mfa_remember_device = each.value.mfa.remember_device_by_default

  session_lifetime   = each.value.session.duration
  session_idle       = each.value.session.idle_timeout
  session_persistent = each.value.session.persistent_cookie_enabled
}
