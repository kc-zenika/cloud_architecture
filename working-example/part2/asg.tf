
resource "aws_autoscaling_group" "app" {
  name             = "part2-app-asg"
  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  vpc_zone_identifier = [for s in aws_subnet.private : s.id]

  # 1. Before ALB created
  # health_check_type         = "EC2"

  # 2. After ALB created
  health_check_type       = "ELB"
  target_group_arns       = [aws_lb_target_group.app_tg.arn]

  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "part2-app-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "part2-app-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.app.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50
  }
}
