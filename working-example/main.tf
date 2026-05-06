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
    bucket         = "workshop-tfstate-211945238520"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

####################
###### Part 2 ######
####################

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
        { rule_no = 100, protocol = "tcp", action = "allow", cidr_block = "0.0.0.0/0", from_port = 80, to_port = 80 },
        { rule_no = 110, protocol = "tcp", action = "allow", cidr_block = "0.0.0.0/0", from_port = 443, to_port = 443 },
        { rule_no = 120, protocol = "tcp", action = "allow", cidr_block = "0.0.0.0/0", from_port = 1024, to_port = 65535 }
      ]
      egress = [
        { rule_no = 100, protocol = "tcp", action = "allow", cidr_block = "0.0.0.0/0", from_port = 80, to_port = 80 },
        { rule_no = 110, protocol = "tcp", action = "allow", cidr_block = "0.0.0.0/0", from_port = 443, to_port = 443 },
        { rule_no = 120, protocol = "tcp", action = "allow", cidr_block = "0.0.0.0/0", from_port = 1024, to_port = 65535 }
      ]
    }
    private = {
      ingress = [
        { rule_no = 100, protocol = "tcp", action = "allow", cidr_block = "10.0.0.0/16", from_port = 80, to_port = 80 },
        { rule_no = 110, protocol = "tcp", action = "allow", cidr_block = "10.0.0.0/16", from_port = 443, to_port = 443 },
        { rule_no = 120, protocol = "tcp", action = "allow", cidr_block = "0.0.0.0/0", from_port = 1024, to_port = 65535 }
      ]
      egress = [
        { rule_no = 100, protocol = "tcp", action = "allow", cidr_block = "0.0.0.0/0", from_port = 80, to_port = 80 },
        { rule_no = 110, protocol = "tcp", action = "allow", cidr_block = "0.0.0.0/0", from_port = 443, to_port = 443 },
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

# 2.8 Security groups

## security group for alb
resource "aws_security_group" "alb" {
  name        = "alb"
  description = "Public ALB Security Group"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "alb_in_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "alb_in_https" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "alb_out_app_http" {
  security_group_id = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_out_app_https" {
  security_group_id = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}


## security group for app
resource "aws_security_group" "app" {
  name        = "app"
  description = "Private App Security Group"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "app_in_http" {
  security_group_id = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "app_in_https" {
  security_group_id = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "app_out_https" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
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
      "arn:aws:s3:::daas-211945238520",
			"arn:aws:s3:::daas-211945238520/*"
    ]
  }
}

resource "aws_iam_policy" "app_policy" {
  name   = "DaaSAppPolicy"
  description = "Permissions for the DaaS application"
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

resource "aws_iam_role" "app_role" {
  name               = "DaaSAppRole"
  assume_role_policy = data.aws_iam_policy_document.app_role_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "app_policy_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.app_policy.arn
}

resource "aws_iam_role_policy_attachment" "app_ssm_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# 3.5 EC2 instance profile
resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "DaaSInstanceProfile"
  role = aws_iam_role.app_role.name
}

# 3.6 Interface VPC endpoint for SSM
locals {
  ssm_services = ["ssm", "ssmmessages", "ec2messages"]
}

resource "aws_security_group" "ssm_vpce_sg" {
  name        = "ssm-vpce"
  description = "Allow nodes to talk to SSM Endpoints"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "ssm_vpce_in_https" {
  security_group_id = aws_security_group.ssm_vpce_sg.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "ssm_vpce_out_https" {
  security_group_id = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.ssm_vpce_sg.id
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
}

resource "aws_vpc_endpoint" "ssm_endpoints" {
  # creates 3 vpc endpoints required for ssm
  for_each = toset(local.ssm_services)

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-southeast-1.${each.key}"
  vpc_endpoint_type = "Interface"

  subnet_ids = [for s in aws_subnet.private : s.id]

  # This allows the 'ssm.ap-southeast-1.amazonaws.com' URL 
  # to resolve to the private endpoint IP
  private_dns_enabled = true

  security_group_ids = [aws_security_group.ssm_vpce_sg.id]
}


####################
###### Part 4 ######
####################

# EC2
resource "aws_instance" "web_server" {
  ami           = "ami-0135b39e8099fe53c"
  instance_type = "t3.micro"

  user_data = file("user_data.sh")
  subnet_id = aws_subnet.private["ap-southeast-1a"].id

  iam_instance_profile = aws_iam_instance_profile.app_instance_profile.name
  vpc_security_group_ids = [aws_security_group.app.id]
}

# NAT
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public["ap-southeast-1a"].id

  tags = {
    Name = "nat-main"
  }

  depends_on = [aws_internet_gateway.main]
}

# Route table in private subnets to NAT for internet outbound
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = { Name = "rt-private" }
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}


# Gateway VPCe for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = "Gateway"

  # This automatically injects the S3 route into these route tables
  route_table_ids = [aws_route_table.private.id]
}

# ALB
resource "aws_lb" "app_alb" {
  name               = "app-alb-internet"
  internal           = false # internet-facing
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [for s in aws_subnet.public : s.id]

}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/index.html"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "web_app_attach" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.web_server.id
  port             = 80
}

# ALB listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
