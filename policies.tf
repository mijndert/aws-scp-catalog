locals {
  # Only create policies that are actually attached somewhere.
  # An entry in local.policies with attach_to_root = false and empty
  # ou_names/account_names is treated as disabled and not materialized in AWS.
  enabled_policies = {
    for k, v in local.policies : k => v
    if v.attach_to_root || length(v.ou_names) > 0 || length(v.account_names) > 0
  }
}

resource "aws_organizations_policy" "this" {
  for_each = local.enabled_policies

  name        = each.key
  description = each.value.description
  type        = "SERVICE_CONTROL_POLICY"
  content     = each.value.content
}
