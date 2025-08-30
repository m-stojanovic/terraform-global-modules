resource "tfe_organization" "this" {
  count = var.create_new_organization ? 1 : 0
  name  = var.organization_name
  email = var.organization_email
}

# Should be retrieved from tfe_oauth_client.this.oauth_token_id. But access tokesn are supported only in premium Bitbucket plan. Due to that, we handle this manually.
data "aws_secretsmanager_secret" "oauth_token_id" {
  name = "bitbucket/svc.techops.oauth_token_id"
}

data "aws_secretsmanager_secret_version" "oauth_token_id" {
  secret_id = data.aws_secretsmanager_secret.oauth_token_id.id
}

data "aws_secretsmanager_secret" "slack" {
  name = "slack/techops_deployments.webhook"
}

data "aws_secretsmanager_secret_version" "slack" {
  secret_id = data.aws_secretsmanager_secret.slack.id
}

locals {

  organization_name = var.create_new_organization ? tfe_organization.this[0].id : var.organization_name

  # Import org data from json file
  org_data = jsondecode(file("${path.module}/templates/tfc.json"))

  # Extract the workspace data
  raw_workspaces = try(local.org_data.workspaces, [])

  workspaces = [for workspace in local.raw_workspaces : {
    name                = workspace["name"]
    description         = workspace["description"]
    teams               = try(workspace["teams"], [])
    terraform_version   = try(workspace["terraform_version"], "1.9.8")
    tag_names           = try(workspace["tag_names"], [])
    auto_apply          = try(workspace["auto_apply"], false)
    allow_destroy_plan  = try(workspace["auto_apply"], true)
    execution_mode      = try(workspace["execution_mode"], "remote")
    speculative_enabled = try(workspace["speculative_enabled"], true)
    vcs_repo            = try(workspace["vcs_repo"], [])
    remote_state_shared = try(workspace["remote_state_shared"], [])
    working_directory   = workspace["working_directory"]
    run_triggers        = try(workspace["run_triggers"], [])
    trigger_patterns    = try(workspace["trigger_patterns"], [])
  }]

  workspace_names = {
    for w in local.workspaces : w.name => w
  }

  # Create a list of workspace access entries
  workspace_team_access = flatten([
    for workspace in local.workspaces : [
      for team in workspace["teams"] : {
        workspace_name = workspace["name"]
        team_name      = team["name"]
        access_level   = team["access_level"]
      }
    ]
  ])

  shared_workspace_prefixes = {
    for k, v in tfe_workspace.this :
    k => regexall("^(terraform-[^-]+)", k)[0]
    if can(regex(".*-shared$", k))
  }

  # Extract the team data
  raw_teams = try(local.org_data.teams, [])

  # Normalize the teams data, each team at least needs a name
  teams = [for team in local.raw_teams : {
    name                = team["name"]
    visibility          = try(team["visibility"], "secret")
    organization_access = try(team["organization_access"], {})
    members             = try(team["members"], [])
  }]

  raw_projects = try(local.org_data.projects, [])

  workspace_to_project = flatten([
    for project in local.raw_projects : [
      for workspace in project["workspaces"] : {
        workspace_name = workspace
        project_name   = project["name"]
      }
    ]
  ])

  workspace_to_project_map = {
    for wp in local.workspace_to_project : wp.workspace_name => wp.project_name
  }

  run_trigger_entries = flatten([
    for ws in local.workspaces : [
      for dest in ws.run_triggers : {
        source      = ws.name
        destination = dest
      }
    ]
  ])
}

resource "tfe_project" "this" {
  for_each     = { for project in local.raw_projects : project["name"] => project }
  name         = each.value["name"]
  description  = each.value["description"]
  organization = local.organization_name
}

resource "tfe_workspace" "this" {
  for_each            = { for workspace in local.workspaces : workspace["name"] => workspace }
  name                = each.key
  description         = each.value["description"]
  terraform_version   = each.value["terraform_version"]
  organization        = local.organization_name
  tag_names           = each.value["tag_names"]
  auto_apply          = each.value["auto_apply"]
  allow_destroy_plan  = each.value["allow_destroy_plan"]
  speculative_enabled = each.value["speculative_enabled"]
  working_directory   = each.value["working_directory"]
  trigger_patterns    = each.value["trigger_patterns"]
  ssh_key_id          = var.ssh_key_id

  project_id = lookup(
    { for k, v in tfe_project.this : v.name => v.id },
    try(local.workspace_to_project_map[each.key], ""),
    null
  )

  # Create a single vcs_repo block if value isn't an empty map
  dynamic "vcs_repo" {
    for_each = length(each.value.vcs_repo) > 0 ? each.value.vcs_repo : []
    content {
      branch         = lookup(vcs_repo.value, "branch", "")
      identifier     = lookup(vcs_repo.value, "identifier", "")
      oauth_token_id = data.aws_secretsmanager_secret_version.oauth_token_id.secret_string
    }
  }

  depends_on = [tfe_project.this]
}

resource "tfe_workspace_settings" "this" {
  for_each     = { for workspace in local.workspaces : workspace["name"] => workspace }
  workspace_id = lookup(tfe_workspace.this, each.key).id

  global_remote_state = false
  execution_mode      = each.value["execution_mode"]

  remote_state_consumer_ids = [
    for shared in each.value.remote_state_shared :
    tfe_workspace.this[shared].id
    if can(tfe_workspace.this[shared])
  ]
}

resource "tfe_team" "this" {
  for_each     = { for team in local.teams : team["name"] => team }
  name         = each.key
  organization = local.organization_name
  visibility   = each.value["visibility"]

  # Create a single organization_access block if value isn't an empty map
  dynamic "organization_access" {
    for_each = each.value["organization_access"] != {} ? toset(["1"]) : toset([])

    content {
      # Get the value for each permission if it exists, set to false if it doesn't
      manage_policies         = try(each.value.organization_access["manage_policies"], false)
      manage_policy_overrides = try(each.value.organization_access["manage_policy_overrides"], false)
      manage_workspaces       = try(each.value.organization_access["manage_workspaces"], false)
      manage_vcs_settings     = try(each.value.organization_access["manage_vcs_settings"], false)
    }
  }
}

# Configure workspace access for teams
resource "tfe_team_access" "this" {
  for_each     = { for access in local.workspace_team_access : "${access.workspace_name}_${access.team_name}" => access }
  access       = each.value["access_level"]
  team_id      = tfe_team.this[each.value["team_name"]].id
  workspace_id = tfe_workspace.this[each.value["workspace_name"]].id
}

resource "tfe_organization_membership" "this" {
  for_each     = toset(flatten(local.teams.*.members))
  organization = local.organization_name
  email        = each.value
}

locals {
  # Create a list of member mappings like this
  # team_name = team_name
  # member_name = member_email
  team_members = flatten([
    for team in local.teams : [
      for member in team["members"] : {
        team_name   = team["name"]
        member_name = member
      } if length(team["members"]) > 0
    ]
  ])
}

resource "tfe_team_organization_member" "this" {
  # Create a map with the team name and member name combines as a key for uniqueness
  for_each                   = { for member in local.team_members : "${member.team_name}_${member.member_name}" => member }
  team_id                    = tfe_team.this[each.value["team_name"]].id
  organization_membership_id = tfe_organization_membership.this[each.value["member_name"]].id
}

resource "tfe_registry_module" "this" {
  organization    = local.organization_name
  initial_version = "1.0.0"
  vcs_repo {
    branch             = "main"
    display_identifier = "devops/terraform-global-modules"
    identifier         = "devops/terraform-global-modules"
    oauth_token_id     = data.aws_secretsmanager_secret_version.oauth_token_id.secret_string
  }
  test_config {
    tests_enabled = false
  }
}

resource "tfe_notification_configuration" "this" {
  for_each         = { for workspace in local.workspaces : workspace["name"] => workspace }
  workspace_id     = lookup(tfe_workspace.this, each.key).id
  destination_type = "slack"
  enabled          = true
  url              = data.aws_secretsmanager_secret_version.slack.secret_string
  name             = "${each.key}-slack-notification"
  triggers         = ["run:created", "run:completed", "run:errored"]
}

# resource "tfe_oauth_client" "this" {
#   name                = "bitbucket"
#   organization        = local.organization_name
#   api_url             = "https://api.bitbucket.org/2.0"
#   http_url            = "https://bitbucket.org"
#   key                 = "" # Retrieved from the Bitbucket consumer integration
#   secret              = ""
#   oauth_token         = "" # Access tokens are supported in Premium Bitbucket plan. 
#   service_provider    = "bitbucket_hosted"
#   organization_scoped = true
# }

############## TFE Variable Sets ##############
resource "tfe_variable_set" "tfvars" {
  for_each = {
    for k, v in tfe_workspace.this :
    k => v
    if can(regex(".*-infrastructure-(dev|stg|prod)$", k))
  }

  # Use the workspace name to differentiate each variable set
  name         = "env-tfvars-${local.workspace_names[each.key].tag_names[0]}-${split("-", each.key)[length(split("-", each.key)) - 1]}"
  description  = "The tfvars file per environment for workspace ${each.key}"
  organization = local.organization_name
}

resource "tfe_workspace_variable_set" "tfvars" {
  for_each = tfe_variable_set.tfvars

  variable_set_id = each.value.id
  workspace_id    = tfe_workspace.this[each.key].id
}

resource "tfe_variable_set" "aws" {
  for_each = {
    for k, v in tfe_workspace.this :
    k => v
    if can(regex(".*-shared$", k))
  }

  name         = "aws-credentials-${local.workspace_names[each.key].tag_names[0]}-${split("-", each.key)[length(split("-", each.key)) - 1]}"
  description  = "AWS Credentials for workspace ${each.key}"
  organization = local.organization_name
}

resource "tfe_workspace_variable_set" "aws_shared" {
  for_each = tfe_variable_set.aws

  variable_set_id = each.value.id
  workspace_id    = tfe_workspace.this[each.key].id
}

resource "tfe_workspace_variable_set" "aws_infrastructure" {
  for_each = {
    for k, v in tfe_workspace.this :
    k => v
    if can(regex(".*-infrastructure-(dev|stg|prod)$", k))                               # Match relevant workspaces
    && contains(keys(tfe_variable_set.aws), "${split("-infrastructure", k)[0]}-shared") # Ensure matching variable set exists
  }

  variable_set_id = tfe_variable_set.aws["${split("-infrastructure", each.key)[0]}-shared"].id
  workspace_id    = each.value.id
}

################ TFE Variables ################
resource "tfe_variable" "tf_cli_args" {
  for_each = tfe_variable_set.tfvars

  variable_set_id = each.value.id
  key             = "TF_CLI_ARGS_plan"
  # Use the workspace name to pick "dev", "stg" or "prod"
  value     = "-var-file=\"./env_vars/${split("-", each.key)[length(split("-", each.key)) - 1]}.tfvars\""
  category  = "env"
  sensitive = false
  hcl       = false
}



############## TFE Run triggers ##############
resource "tfe_run_trigger" "this" {
  # Using each pair’s source/destination to make a unique map key
  # [
  #   {
  #     source      = "terraform-${project}-infrastructure-dev"
  #     destination = "terraform-${project}-infrastructure-stg"
  #   },
  #   {
  #     source      = "terraform-${project}-infrastructure-stg"
  #     destination = "terraform-${project}-infrastructure-prod"
  #   },
  #   ...
  # ]
  for_each = {
    for rt in local.run_trigger_entries :
    "${rt.source}_to_${rt.destination}" => rt
  }

  sourceable_id = tfe_workspace.this[each.value.source].id
  workspace_id  = tfe_workspace.this[each.value.destination].id
}
