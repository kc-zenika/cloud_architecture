terraform {
  required_version = ">= 1.11"

  # aws provider
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.38"
    }
  }

  # backend
  backend "s3" {
    bucket       = "workshop-tfstate-942195279338"
    key          = "terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true
    encrypt      = true
  }
}

locals {
  account_id  = "942195279338"
}