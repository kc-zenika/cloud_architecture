terraform {
  required_version = ">= 1.0"

  # local provider
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67"
    }
  }

  # backend
  backend "s3" {
    bucket         = "workshop-tfstate-787525931078"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

