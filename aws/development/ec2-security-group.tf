# Security group for the app instances.
resource "aws_security_group" "app" {
  name        = "part2-app"
  description = "Private App Security Group"
  vpc_id      = aws_vpc.main.id
}

# resource "aws_vpc_security_group_ingress_rule" "app_in_http" {
#   security_group_id            = aws_security_group.app.id
#   referenced_security_group_id = aws_security_group.alb.id
#   ip_protocol                  = "tcp"
#   from_port                    = 8080
#   to_port                      = 8080
# }

resource "aws_vpc_security_group_egress_rule" "app_out_https" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}
