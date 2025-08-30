terraform {
  required_providers {
    okta = {
      source = "okta/okta"
    }
  }
}

resource "okta_app_saml" "this" {
  label  = var.app_label
  status = "ACTIVE"

  sso_url     = var.sso_url
  recipient   = var.sso_url
  destination = var.sso_url
  audience    = var.audience

  subject_name_id_template = var.subject_name_id_template
  subject_name_id_format   = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

  response_signed     = true
  assertion_signed    = true
  signature_algorithm = "RSA_SHA256"
  digest_algorithm    = "SHA256"

  honor_force_authn  = false
  request_compressed = true

  single_logout_url    = var.single_logout_url
  single_logout_issuer = var.single_logout_issuer

  authn_context_class_ref = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"

  attribute_statements {
    name         = "groups"
    type         = "GROUP"
    filter_type  = "REGEX"
    filter_value = ".*"
  }

  attribute_statements {
    name   = "email"
    type   = "EXPRESSION"
    values = ["user.email"]
  }

  attribute_statements {
    name   = "name"
    type   = "EXPRESSION"
    values = ["user.firstName + ' ' + user.lastName"]
  }
}

resource "okta_app_group_assignments" "this" {
  app_id = okta_app_saml.this.id

  dynamic "group" {
    for_each = var.okta_groups
    content {
      id       = group.value.id
      priority = lookup(group.value, "priority", 0)
      profile  = lookup(group.value, "profile", null) != null ? jsonencode(group.value.profile) : null
    }
  }
}
