terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.33"
    }
  }
}

provider "aws" {
    profile  = var.provider_aws_profile
    region = var.provider_aws_region
}

data "aws_caller_identity" "current" {}