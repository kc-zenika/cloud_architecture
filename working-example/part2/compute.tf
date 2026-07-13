# Compute layer (launch template + ASG + scaling policy) -- see modules/asg.
# Replaces the resources that used to live directly in asg.tf and
# launch-template.tf (kept there, commented out, as a before/after reference).
module "asg" {
  source = "./modules/asg"

  name                      = "part2-app"
  iam_instance_profile_name = aws_iam_instance_profile.app_instance_profile.name
  security_group_ids        = [aws_security_group.app.id]
  subnet_ids                = [for s in aws_subnet.private : s.id]
  target_group_arns         = [aws_lb_target_group.app_tg.arn]

  user_data = base64encode(templatefile("${path.module}/../../assets/user_data.template", {
    bucket_name = "workshop-part2-app-${local.account_id}"
  }))

  min_size         = 2
  max_size         = 4
  desired_capacity = 2
}

moved {
  from = aws_launch_template.app
  to   = module.asg.aws_launch_template.app
}

moved {
  from = aws_autoscaling_group.app
  to   = module.asg.aws_autoscaling_group.app
}

moved {
  from = aws_autoscaling_policy.cpu_target_tracking
  to   = module.asg.aws_autoscaling_policy.cpu_target_tracking
}
