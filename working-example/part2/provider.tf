terraform {
  required_version = ">= 1.0"

  # aws provider
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.38"
    }
  }

  # backend
  backend "s3" {
    bucket         = "workshop-tfstate-211945238520"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}