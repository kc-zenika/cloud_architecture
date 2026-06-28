# Interface VPC endpoint for SSM
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

# Gateway VPCe for S3
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = "Gateway"

  # This automatically injects the S3 route into these route tables
  route_table_ids = [aws_route_table.private.id]
}
