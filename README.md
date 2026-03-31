# AWS Service Control Policies Catalog

A reusable OpenTofu (Terraform) configuration for managing AWS Organizations Service Control Policies (SCPs).

> [!IMPORTANT]
> This module is designed to be used as a starting point for managing SCPs in your AWS Organization. It provides a set of common policies and a flexible structure for defining and attaching them. You should review and customize the policies and attachment logic to fit your organization's specific needs and security requirements. The author is not responsible for any misconfigurations or security issues that may arise from using this module without proper review and customization.

## Features

- **Direct data source references**: Define policies with inline references to policy documents
- **Flexible attachments**: Attach SCPs to the organization root, specific OUs by name, or specific accounts by name
- **Easy to extend**: Add new policy documents and reference them directly
- **DRY principle**: Loop-based approach eliminates repetitive resource definitions

## Pre-requisites

- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate permissions
- [OpenTofu](https://opentofu.org/) installed
- [Taskfile](https://taskfile.dev/) installed (optional, for easier command management)

## Pre-existing Organization Structure

If you already have an AWS Organization that you want to manage using this module, you can import the exisitng organization. This will allow the module to enable the Service Control Policy (SCP) feature.

```bash
task run cmd=import -- aws_organizations_organization.this $(aws organizations describe-organization --query 'Organization.Id' --output text)
```

## Usage

### 1. Configure your organization settings

Edit `config/organization.tfvars`:

```hcl
aws_region           = "eu-west-1"                              # Replace with your desired AWS region
environment          = "organization"                           # Used for naming conventions
state_bucket_name    = "mycompany-organization-terraform-state" # Replace with the name of your S3 bucket for the statefile
organization_root_id = "r-xxxx"                                 # Replace with your organization root ID
```

> [!TIP]
> Use the [Remote State](https://github.com/mijndert/aws-remote-state) module to set up your S3 bucket for storing the statefile and ensuring versioning, server-side encryption, and proper access controls are in place.

### 2. Enabling SCPs

Edit `policy_documents.tf`:

- Set `attach_to_root` to `true` for the policies you want to attach to the organization root
- Set `attach_to_root` to `false` for policies you want to attach based on OU or account names, and fill in the `ou_names` and `account_names` lists accordingly
- If you don't want to use a specific policy, set `attach_to_root` to `false` and leave the `ou_names` and `account_names` lists empty

### 3. Adding a new SCP

1. **Add the policy document** in `policy_documents.tf`:

```hcl
data "aws_iam_policy_document" "my_new_policy" {
  statement {
    sid       = "MyNewPolicy"
    effect    = "Deny"
    actions   = ["service:Action"]
    resources = ["*"]
  }
}
```

2. **Add the policy** to `local.policies` in `policy_documents.tf`:

```hcl
locals {
  policies = {
    # ... existing policies ...

    "MyNewPolicy" = {
      description    = "My new policy description"
      content        = data.aws_iam_policy_document.my_new_policy.json
      attach_to_root = false
      ou_names       = ["Production"]
      account_names  = ["shared-services"]
    }
  }
}
```

## Available Policy Documents

| Name                         | Description                                            |
| ---------------------------- | ------------------------------------------------------ |
| `DenyLeaveOrganization`      | Prevents member accounts from leaving the organization |
| `DenyRootUser`               | Prevents the root user from performing any actions     |
| `AllowApprovedInstanceTypes` | Allows only approved EC2 instance types to be launched |
| `DenyDeleteEKSClusters`      | Prevents deletion of EKS clusters                      |
| `DenyDisableCloudTrail`      | Prevents disabling or deleting CloudTrail              |
| `DenyS3PublicAccess`         | Prevents making S3 buckets or objects public           |
| `DenyRootAccessKeys`         | Prevents creation of access keys for the root user     |
| `RequireIMDSv2`              | Requires IMDSv2 for all EC2 instances                  |
| `DenyDisableGuardDuty`       | Prevents disabling or deleting GuardDuty               |
| `DenyDisableConfig`          | Prevents disabling AWS Config                          |
| `DenyDeleteVPCFlowLogs`      | Prevents deletion of VPC Flow Logs                     |
| `RequireEncryptedEBS`        | Requires encryption for EBS volumes                    |
| `RequireEncryptedRDS`        | Requires encryption for RDS instances and clusters     |
| `DenyDisableSecurityHub`     | Prevents disabling Security Hub                        |

## SCP Configuration Options

| Field            | Type         | Description                                                                  |
| ---------------- | ------------ | ---------------------------------------------------------------------------- |
| `description`    | string       | Human-readable description of the SCP                                        |
| `content`        | string       | Reference to `data.aws_iam_policy_document.<name>.json`                      |
| `attach_to_root` | bool         | If `true`, attaches to organization root. If `false`, uses name-based lists  |
| `ou_names`       | list(string) | List of OU names to attach to (only used when `attach_to_root = false`)      |
| `account_names`  | list(string) | List of account names to attach to (only used when `attach_to_root = false`) |

## Deployment

### Using OpenTofu directly

```bash
# Initialize OpenTofu
tofu init

# Plan with your configuration
tofu plan -var-file=config/organization.tfvars

# Apply changes
tofu apply -var-file=config/organization.tfvars
```

### Using Taskfile

This project includes a `Taskfile.yml` for use with [Taskfile](https://taskfile.dev/):

```bash
# Plan changes
task plan

# Apply changes
task apply

# Destroy resources
task destroy
```
