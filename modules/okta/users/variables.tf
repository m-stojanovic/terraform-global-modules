variable "users" {
  description = <<EOT
    List of user definitions to create in Okta. 
    Each user object must include a 'user' (email address), which is used as the base for login, first_name, and last_name unless overridden. 
    Optional fields allow full customization of user profile attributes.
  EOT
  type = list(object({
    ## Identity
    login            = optional(string)
    status           = optional(string)
    first_name       = optional(string)
    last_name        = optional(string)
    middle_name      = optional(string)
    honorific_prefix = optional(string)
    honorific_suffix = optional(string)
    nick_name        = optional(string)
    display_name     = optional(string)
    ## Contacts
    email         = string
    second_email  = optional(string)
    mobile_phone  = optional(string)
    primary_phone = optional(string)
    profile_url   = optional(string)
    ## Address
    street_address = optional(string)
    postal_address = optional(string)
    city           = optional(string)
    state          = optional(string)
    zip_code       = optional(string)
    country_code   = optional(string)
    ## Organizational Information
    organization    = optional(string)
    division        = optional(string)
    department      = optional(string)
    cost_center     = optional(string)
    title           = optional(string)
    user_type       = optional(string)
    employee_number = optional(string)
    manager         = optional(string)
    manager_id      = optional(string)
    ## Preferences
    locale             = optional(string)
    timezone           = optional(string)
    preferred_language = optional(string)
  }))
}
