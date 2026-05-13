terraform {
  # OpenTofu >= 1.8 is required: state.tf uses variable interpolation
  # inside the backend block, which Terraform does not support.
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
