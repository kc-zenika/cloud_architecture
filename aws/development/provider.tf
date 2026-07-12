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
    bucket       = "workshop-tfstate-<ACCOUNT_ID>"
    key          = "terraform.tfstate"
    region       = "ap-southeast-1"
    use_lockfile = true # makes the S3 backend do locking without DynamoDB
    encrypt      = true
  }
}
