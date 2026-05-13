# Flatten the OU and account name attachments into a map for for_each
locals {
  ou_attachments = merge([
    for policy_name, policy_config in local.policies : {
      for ou_name in policy_config.ou_names :
      "${policy_name}-${ou_name}" => {
        policy_name = policy_name
        ou_name     = ou_name
      }
    } if !policy_config.attach_to_root && length(policy_config.ou_names) > 0
  ]...)

  account_attachments = merge([
    for policy_name, policy_config in local.policies : {
      for account_name in policy_config.account_names :
      "${policy_name}-${account_name}" => {
        policy_name  = policy_name
        account_name = account_name
      }
    } if !policy_config.attach_to_root && length(policy_config.account_names) > 0
  ]...)

  root_attachments = {
    for policy_name, policy_config in local.policies :
    policy_name => policy_config if policy_config.attach_to_root
  }

  # SCP counts per target, used by quota preconditions below.
  # AWS allows at most 5 SCPs per target (root/OU/account), and the
  # AWS-managed FullAWSAccess policy counts toward this limit unless detached.
  ou_scp_counts = {
    for ou_name, policies in {
      for k, v in local.ou_attachments : v.ou_name => k...
    } : ou_name => length(policies)
  }

  account_scp_counts = {
    for account_name, policies in {
      for k, v in local.account_attachments : v.account_name => k...
    } : account_name => length(policies)
  }

  scp_quota_per_target = 5
}

resource "aws_organizations_policy_attachment" "ou" {
  for_each = local.ou_attachments

  policy_id = aws_organizations_policy.this[each.value.policy_name].id
  target_id = local.ou_name_to_id[each.value.ou_name]

  lifecycle {
    precondition {
      condition     = local.ou_scp_counts[each.value.ou_name] <= local.scp_quota_per_target
      error_message = "AWS allows at most 5 SCPs per target. OU '${each.value.ou_name}' has ${local.ou_scp_counts[each.value.ou_name]} attachments in this config; the AWS-managed FullAWSAccess SCP (attached by default) also counts toward this limit."
    }
  }
}

resource "aws_organizations_policy_attachment" "account" {
  for_each = local.account_attachments

  policy_id = aws_organizations_policy.this[each.value.policy_name].id
  target_id = local.account_name_to_id[each.value.account_name]

  lifecycle {
    precondition {
      condition     = local.account_scp_counts[each.value.account_name] <= local.scp_quota_per_target
      error_message = "AWS allows at most 5 SCPs per target. Account '${each.value.account_name}' has ${local.account_scp_counts[each.value.account_name]} attachments in this config; the AWS-managed FullAWSAccess SCP (attached by default) also counts toward this limit."
    }
  }
}

resource "aws_organizations_policy_attachment" "root" {
  for_each = local.root_attachments

  policy_id = aws_organizations_policy.this[each.key].id
  target_id = var.organization_root_id

  lifecycle {
    precondition {
      condition     = length(local.root_attachments) <= local.scp_quota_per_target
      error_message = "AWS allows at most 5 SCPs per target. Organization root has ${length(local.root_attachments)} attachments in this config; the AWS-managed FullAWSAccess SCP (attached by default) also counts toward this limit."
    }
  }
}
