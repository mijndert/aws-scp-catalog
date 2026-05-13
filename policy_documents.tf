locals {
  policies = {
    "DenyLeaveOrganization" = {
      description    = "Prevents member accounts from leaving the organization"
      content        = data.aws_iam_policy_document.deny_leaving_organization.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "DenyRootUser" = {
      description    = "Prevents the root user from performing any actions"
      content        = data.aws_iam_policy_document.deny_root_user.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "AllowApprovedInstanceTypes" = {
      description    = "Allows only approved EC2 instance types to be launched"
      content        = data.aws_iam_policy_document.allow_approved_instance_types.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "DenyDeleteEKSClusters" = {
      description    = "Prevents deletion of EKS clusters"
      content        = data.aws_iam_policy_document.deny_delete_eks_clusters.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "DenyDisableCloudTrail" = {
      description    = "Prevents disabling or deleting CloudTrail"
      content        = data.aws_iam_policy_document.deny_disable_cloudtrail.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "DenyS3PublicAccess" = {
      description    = "Prevents making S3 buckets or objects public"
      content        = data.aws_iam_policy_document.deny_s3_public_access.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "DenyRootAccessKeys" = {
      description    = "Prevents creation of access keys for the root user"
      content        = data.aws_iam_policy_document.deny_root_access_keys.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "RequireIMDSv2" = {
      description    = "Requires IMDSv2 for all EC2 instances"
      content        = data.aws_iam_policy_document.require_imdsv2.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "DenyDisableGuardDuty" = {
      description    = "Prevents disabling or deleting GuardDuty"
      content        = data.aws_iam_policy_document.deny_disable_guardduty.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "DenyDisableConfig" = {
      description    = "Prevents disabling AWS Config"
      content        = data.aws_iam_policy_document.deny_disable_config.json
      attach_to_root = true
      ou_names       = []
      account_names  = []
    }
    "DenyDeleteVPCFlowLogs" = {
      description    = "Prevents deletion of VPC Flow Logs"
      content        = data.aws_iam_policy_document.deny_delete_vpc_flow_logs.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "RequireEncryptedEBS" = {
      description    = "Requires encryption for EBS volumes"
      content        = data.aws_iam_policy_document.require_encrypted_ebs.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "RequireEncryptedRDS" = {
      description    = "Requires encryption for RDS instances and clusters"
      content        = data.aws_iam_policy_document.require_encrypted_rds.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "DenyDisableSecurityHub" = {
      description    = "Prevents disabling Security Hub"
      content        = data.aws_iam_policy_document.deny_disable_security_hub.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "DenyCreateIAMUser" = {
      description    = "Prevents creation of IAM users and their access keys"
      content        = data.aws_iam_policy_document.deny_create_iam_user.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "DenyRootMFADeactivation" = {
      description    = "Prevents deactivating or deleting MFA devices for the root user"
      content        = data.aws_iam_policy_document.deny_root_mfa_deactivation.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "DenyDeleteCloudWatchLogs" = {
      description    = "Prevents deletion of CloudWatch log groups, log streams, and retention policies"
      content        = data.aws_iam_policy_document.deny_delete_cloudwatch_logs.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "DenyPublicSnapshots" = {
      description    = "Prevents sharing EBS and RDS snapshots publicly"
      content        = data.aws_iam_policy_document.deny_public_snapshots.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "DenyKMSKeyDeletion" = {
      description    = "Prevents scheduling deletion or disabling of KMS keys"
      content        = data.aws_iam_policy_document.deny_kms_key_deletion.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
    "RequireS3TLS" = {
      description    = "Requires TLS (HTTPS) for all S3 requests"
      content        = data.aws_iam_policy_document.require_s3_tls.json
      attach_to_root = false
      ou_names       = []
      account_names  = []
    }
  }
}

data "aws_iam_policy_document" "deny_leaving_organization" {
  statement {
    sid       = "DenyLeaveOrganization"
    effect    = "Deny"
    actions   = ["organizations:LeaveOrganization"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "deny_root_user" {
  statement {
    sid       = "DenyRootUser"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:root"]
    }
  }
}

data "aws_iam_policy_document" "allow_approved_instance_types" {
  statement {
    sid       = "AllowApprovedInstanceTypes"
    effect    = "Deny"
    actions   = ["ec2:RunInstances"]
    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "ec2:InstanceType"
      values   = ["t3.micro", "t3.small", "t3.medium"]
    }
  }
}

data "aws_iam_policy_document" "deny_delete_eks_clusters" {
  statement {
    sid       = "DenyDeleteEKSClusters"
    effect    = "Deny"
    actions   = ["eks:DeleteCluster"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "deny_disable_cloudtrail" {
  statement {
    sid    = "DenyDisableCloudTrail"
    effect = "Deny"
    actions = [
      "cloudtrail:DeleteTrail",
      "cloudtrail:StopLogging",
      "cloudtrail:UpdateTrail",
      "cloudtrail:PutEventSelectors",
      "cloudtrail:PutInsightSelectors",
      "cloudtrail:DeleteEventDataStore",
      "cloudtrail:UpdateEventDataStore",
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "deny_s3_public_access" {
  statement {
    sid    = "DenyS3PublicACLs"
    effect = "Deny"
    actions = [
      "s3:PutBucketAcl",
      "s3:PutObjectAcl"
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["public-read", "public-read-write", "authenticated-read"]
    }
  }

  statement {
    sid    = "DenyDeleteAccountPublicAccessBlock"
    effect = "Deny"
    actions = [
      "s3:DeleteAccountPublicAccessBlock",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "DenyWeakeningAccountPublicAccessBlock"
    effect = "Deny"
    actions = [
      "s3:PutAccountPublicAccessBlock",
    ]
    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "s3:PublicAccessBlockConfiguration.BlockPublicAcls"
      values   = ["false"]
    }
  }

  statement {
    sid    = "DenyWeakeningBucketPublicAccessBlock"
    effect = "Deny"
    actions = [
      "s3:PutBucketPublicAccessBlock",
      "s3:PutAccessPointPublicAccessBlock",
    ]
    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "s3:PublicAccessBlockConfiguration.BlockPublicPolicy"
      values   = ["false"]
    }
  }
}

data "aws_iam_policy_document" "deny_root_access_keys" {
  statement {
    sid       = "DenyRootAccessKeys"
    effect    = "Deny"
    actions   = ["iam:CreateAccessKey"]
    resources = ["arn:aws:iam::*:root"]
  }
}

# Require IMDSv2 for EC2 instances
data "aws_iam_policy_document" "require_imdsv2" {
  statement {
    sid       = "RequireIMDSv2OnLaunch"
    effect    = "Deny"
    actions   = ["ec2:RunInstances"]
    resources = ["arn:aws:ec2:*:*:instance/*"]

    condition {
      test     = "StringNotEquals"
      variable = "ec2:MetadataHttpTokens"
      values   = ["required"]
    }
  }

  # AWS does not expose a condition key for the HttpTokens parameter on
  # ec2:ModifyInstanceMetadataOptions, so the only way to prevent post-launch
  # downgrades to IMDSv1 is to block the action outright.
  statement {
    sid       = "DenyIMDSDowngrade"
    effect    = "Deny"
    actions   = ["ec2:ModifyInstanceMetadataOptions"]
    resources = ["*"]
  }
}

# Deny disabling GuardDuty
data "aws_iam_policy_document" "deny_disable_guardduty" {
  statement {
    sid    = "DenyDisableGuardDuty"
    effect = "Deny"
    actions = [
      "guardduty:DeleteDetector",
      "guardduty:DisassociateFromMasterAccount",
      "guardduty:DisassociateMembers",
      "guardduty:StopMonitoringMembers",
      "guardduty:UpdateDetector",
      "guardduty:UpdateMemberDetectors",
      "guardduty:UpdateOrganizationConfiguration",
      "guardduty:DeletePublishingDestination",
      "guardduty:UpdatePublishingDestination",
    ]
    resources = ["*"]
  }
}

# Deny disabling AWS Config
data "aws_iam_policy_document" "deny_disable_config" {
  statement {
    sid    = "DenyDisableConfig"
    effect = "Deny"
    actions = [
      "config:DeleteConfigRule",
      "config:DeleteConfigurationRecorder",
      "config:DeleteDeliveryChannel",
      "config:DeleteConfigurationAggregator",
      "config:DeleteOrganizationConfigRule",
      "config:DeleteRetentionConfiguration",
      "config:StopConfigurationRecorder",
      "config:PutConfigurationRecorder",
      "config:PutDeliveryChannel",
    ]
    resources = ["*"]
  }
}

# Deny disabling VPC Flow Logs
data "aws_iam_policy_document" "deny_delete_vpc_flow_logs" {
  statement {
    sid       = "DenyDeleteVPCFlowLogs"
    effect    = "Deny"
    actions   = ["ec2:DeleteFlowLogs"]
    resources = ["*"]
  }
}

# Deny creating unencrypted EBS volumes
data "aws_iam_policy_document" "require_encrypted_ebs" {
  statement {
    sid       = "RequireEncryptedEBS"
    effect    = "Deny"
    actions   = ["ec2:CreateVolume"]
    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "ec2:Encrypted"
      values   = ["false"]
    }
  }
}

# Deny creating unencrypted RDS instances
data "aws_iam_policy_document" "require_encrypted_rds" {
  statement {
    sid    = "RequireEncryptedRDS"
    effect = "Deny"
    actions = [
      "rds:CreateDBInstance",
      "rds:CreateDBCluster"
    ]
    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "rds:StorageEncrypted"
      values   = ["false"]
    }
  }
}

# Deny disabling Security Hub
data "aws_iam_policy_document" "deny_disable_security_hub" {
  statement {
    sid    = "DenyDisableSecurityHub"
    effect = "Deny"
    actions = [
      "securityhub:DisableSecurityHub",
      "securityhub:DeleteMembers",
      "securityhub:DisassociateMembers"
    ]
    resources = ["*"]
  }
}

# Deny creating IAM users and their access keys (enforce SSO/federated identity)
data "aws_iam_policy_document" "deny_create_iam_user" {
  statement {
    sid    = "DenyCreateIAMUser"
    effect = "Deny"
    actions = [
      "iam:CreateUser",
      "iam:CreateLoginProfile",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "DenyCreateIAMUserAccessKey"
    effect    = "Deny"
    actions   = ["iam:CreateAccessKey"]
    resources = ["arn:aws:iam::*:user/*"]
  }
}

# Deny deactivating or deleting MFA devices for the root user
data "aws_iam_policy_document" "deny_root_mfa_deactivation" {
  statement {
    sid    = "DenyRootMFADeactivation"
    effect = "Deny"
    actions = [
      "iam:DeactivateMFADevice",
      "iam:DeleteVirtualMFADevice",
    ]
    resources = [
      "arn:aws:iam::*:root",
      "arn:aws:iam::*:mfa/root-account-mfa-device",
    ]
  }
}

# Deny deleting CloudWatch log groups, log streams, and retention policies
data "aws_iam_policy_document" "deny_delete_cloudwatch_logs" {
  statement {
    sid    = "DenyDeleteCloudWatchLogs"
    effect = "Deny"
    actions = [
      "logs:DeleteLogGroup",
      "logs:DeleteLogStream",
      "logs:DeleteRetentionPolicy",
      "logs:PutRetentionPolicy",
    ]
    resources = ["*"]
  }
}

# Deny sharing EBS and RDS snapshots publicly
data "aws_iam_policy_document" "deny_public_snapshots" {
  statement {
    sid    = "DenyPublicEBSSnapshots"
    effect = "Deny"
    actions = [
      "ec2:ModifySnapshotAttribute",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:Add/group"
      values   = ["all"]
    }
  }

  statement {
    sid    = "DenyPublicRDSSnapshots"
    effect = "Deny"
    actions = [
      "rds:ModifyDBSnapshotAttribute",
      "rds:ModifyDBClusterSnapshotAttribute",
    ]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "rds:AttributeName"
      values   = ["restore"]
    }

    condition {
      test     = "StringEquals"
      variable = "rds:ValuesToAdd"
      values   = ["all"]
    }
  }
}

# Deny scheduling deletion or disabling of KMS keys (and their aliases)
data "aws_iam_policy_document" "deny_kms_key_deletion" {
  statement {
    sid    = "DenyKMSKeyDeletion"
    effect = "Deny"
    actions = [
      "kms:ScheduleKeyDeletion",
      "kms:DisableKey",
      "kms:DeleteAlias",
    ]
    resources = ["*"]
  }
}

# Require TLS (HTTPS) for all S3 requests
data "aws_iam_policy_document" "require_s3_tls" {
  statement {
    sid       = "RequireS3TLS"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}
