# Part 1
terraform {
  required_version = ">= 1.0"

  # aws provider
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

locals {
  public_subnets = {
    "ap-southeast-1a" = "10.0.0.0/22"
    "ap-southeast-1b" = "10.0.4.0/22"
    "ap-southeast-1c" = "10.0.8.0/22"
  }

  private_subnets = {
    "ap-southeast-1a" = "10.0.32.0/19"
    "ap-southeast-1b" = "10.0.64.0/19"
    "ap-southeast-1c" = "10.0.96.0/19"
  }
}


# Part 2
# 2.3 Create a VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-main"
    Environment = "dev"
  }
}


# 2.4 Adding subnets

# resource "aws_subnet" "public_1a" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.0.0/22"
#   availability_zone = "ap-southeast-1a"
#   tags = {
#     Name = "public-1a"
#     Environment = "dev"
#   }
# }
# ...

resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name        = "public-${each.key}"
    Environment = "dev"
  }
}

resource "aws_subnet" "private" {
  for_each = local.private_subnets

  vpc_id            = aws_vpc.main.id
  availability_zone = each.key
  cidr_block        = each.value

  tags = {
    Name        = "private-${each.key}"
    Environment = "dev"
  }
}


# 2.5 Add IGW for internet reachability
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw-main"
    Environment = "dev"
  }
}