resource "aws_launch_template" "lt" {
  name_prefix   = "${var.project_name}-lt"
  image_id      = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"

  tag_specifications {
    resource_type = "instance"

    tags = {
      CreatedBy = "Aasrith"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = var.private_subnets
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  target_group_arns   = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "CreatedBy"
    value               = "Aasrith"
    propagate_at_launch = true
  }
}