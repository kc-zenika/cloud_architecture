# IAM policy: allow the app to download its own binary from S3
data "aws_iam_policy_document" "app_policy" {
  statement {
    sid = "AllowS3Download"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::workshop-part2-app-942195279338",
      "arn:aws:s3:::workshop-part2-app-942195279338/*"
    ]
  }
}

resource "aws_iam_policy" "app_policy" {
  name        = "Part2AppPolicy"
  description = "Permissions for the part2 workshop app"
  policy      = data.aws_iam_policy_document.app_policy.json
}

# IAM role: trust policy allowing EC2 instances to assume this role
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
  name               = "Part2AppRole"
  assume_role_policy = data.aws_iam_policy_document.app_role_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "app_policy_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = aws_iam_policy.app_policy.arn
}

# SSM access for the same debugging workflow as part1 (journalctl, curl
# localhost, etc via Session Manager) -- no VPC endpoints needed here since
# the private subnets already route outbound through vpc.tf's NAT gateway.
resource "aws_iam_role_policy_attachment" "app_ssm_attach" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 instance profile referenced by the launch template in ec2.tf
resource "aws_iam_instance_profile" "app_instance_profile" {
  name = "Part2AppInstanceProfile"
  role = aws_iam_role.app_role.name
}
