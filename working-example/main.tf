####################
###### Part 1 ######
####################

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

####################
###### Part 2 ######
####################

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

## Manualy adding 1 by 1
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


# 2.6 Route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "rt-public"
    Environment = "dev"
  }
}

## Manualy adding 1 by 1
# resource "aws_route_table_association" "public_1a" {
#   subnet_id      = aws_subnet.public["ap-southeast-1a"].id
#   route_table_id = aws_route_table.public.id
# }

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}


# 2.7 - NACLs - public and private
locals {
  nacl_rules = {
    public = {
      ingress = [
        { rule_no = 100, protocol = "tcp", action = "allow", cidr_block = "0.0.0.0/0", from_port = 443, to_port = 443 },
        { rule_no = 120, protocol = "tcp", action = "allow", cidr_block = "0.0.0.0/0", from_port = 1024, to_port = 65535 }
      ]
      egress = [
        { rule_no = 100, protocol = "tcp", action = "allow", cidr_block = "0.0.0.0/0", from_port = 443, to_port = 443 },
        { rule_no = 120, protocol = "tcp", action = "allow", cidr_block = "0.0.0.0/0", from_port = 1024, to_port = 65535 }
      ]
    }
    private = {
      ingress = [
        { rule_no = 100, protocol = "tcp", action = "allow", cidr_block = "10.0.0.0/16", from_port = 443, to_port = 443 },
        { rule_no = 120, protocol = "tcp", action = "allow", cidr_block = "10.0.0.0/16", from_port = 1024, to_port = 65535 }
      ]
      egress = [
        { rule_no = 100, protocol = "tcp", action = "allow", cidr_block = "0.0.0.0/0", from_port = 443, to_port = 443 },
        { rule_no = 120, protocol = "tcp", action = "allow", cidr_block = "10.0.0.0/16", from_port = 1024, to_port = 65535 }
      ]
    }
  }
}

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [for s in aws_subnet.public : s.id]

  dynamic "ingress" {
    for_each = local.nacl_rules.public.ingress
    content {
      protocol   = ingress.value.protocol
      rule_no    = ingress.value.rule_no
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = local.nacl_rules.public.egress
    content {
      protocol   = egress.value.protocol
      rule_no    = egress.value.rule_no
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  tags = { 
    Name = "nacl-public",
    Environment = "dev"
  }
}

resource "aws_network_acl" "private" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = [for s in aws_subnet.private : s.id]

  dynamic "ingress" {
    for_each = local.nacl_rules.private.ingress
    content {
      protocol   = ingress.value.protocol
      rule_no    = ingress.value.rule_no
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = local.nacl_rules.private.egress
    content {
      protocol   = egress.value.protocol
      rule_no    = egress.value.rule_no
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }

  tags = { 
    Name = "nacl-private",
    Environment = "dev"
  }
}

####################
###### Part 3 ######
####################

# 3.3 IAM policy
data "aws_iam_policy_document" "app_policy" {
  statement {
    sid = "AllowS3Download"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::factquacks-787525931078",
			"arn:aws:s3:::factquacks-787525931078/*"
    ]
  }
}

resource "aws_iam_policy" "app_policy" {
  name   = "FactQuacksAppPolicy"
  description = "Permissions for the FactQuacks application"
  policy = data.aws_iam_policy_document.app_policy.json
}


# 3.4 IAM Role
data "aws_iam_policy_document" "app_role_trust_policy" {
  statement {
    sid = "AllowEC2ServiceToAssumeRole"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "factquacks_app_role" {
  name               = "FactQuacksAppRole"
  assume_role_policy = data.aws_iam_policy_document.app_role_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "app_policy_attach" {
  role       = aws_iam_role.factquacks_app_role.name
  policy_arn = aws_iam_policy.app_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.factquacks_app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 3.5 EC2 instance profile
resource "aws_iam_instance_profile" "factquacks_instance_profile" {
  name = "FactQuacksInstanceProfile"
  role = aws_iam_role.factquacks_app_role.name
}
