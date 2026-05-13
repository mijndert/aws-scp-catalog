variable "aws_region" {
  description = "The AWS region to use"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "The environment to deploy to (e.g. production). Used in the state file key."
  type        = string
  default     = "organization"
}

variable "state_bucket_name" {
  description = "Name of the S3 bucket for the OpenTofu statefile"
  type        = string
}

variable "organization_root_id" {
  description = "The root ID of the AWS Organization (e.g., r-xxxx)"
  type        = string

  validation {
    condition     = can(regex("^r-[a-z0-9]{4,32}$", var.organization_root_id))
    error_message = "organization_root_id must match the format r-XXXXX (4-32 lowercase alphanumeric characters after r-)."
  }
}
