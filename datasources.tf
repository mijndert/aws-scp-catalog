locals {
  account_name_to_id = {
    for account in aws_organizations_organization.this.accounts : account.name => account.id
  }
}

# OUs are looked up one level below the organization root only.
# Nested OUs (e.g. "Workloads/Production") are not supported — attaching to
# them by name will fail with a "key not found" error. See README for details.
data "aws_organizations_organizational_units" "root" {
  parent_id = var.organization_root_id
}

locals {
  ou_name_to_id = {
    for ou in data.aws_organizations_organizational_units.root.children : ou.name => ou.id
  }
}
