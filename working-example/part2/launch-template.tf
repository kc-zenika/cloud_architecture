# Superseded by module.asg in compute.tf -- kept here, commented out, as a
# "before" reference for notes/part2/advanced/2.4_tf_modules.md.

# Latest Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "app" {
  name_prefix   = "part2-app-"
  image_id      = data.aws_ami.al2023.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.app_instance_profile.name
  }

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(templatefile("${path.module}/../../assets/user_data.template", {
    bucket_name = "workshop-part2-app-${local.account_id}"
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "part2-app"
    }
  }
}
