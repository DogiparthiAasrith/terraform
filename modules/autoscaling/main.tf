locals {
  common_tags = {
    CreatedBy   = "Aasrith"
    Environment = "dev"
    Project     = "week4"
    Purpose     = "Training Plan"
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "lt" {
  name = "${var.project_name}-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [var.security_group_id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello from Terraform ASG!" > index.html
              nohup python3 -m http.server 80 &
              EOF
  )

  # Removed tag_specifications for instance to avoid conflict with ASG tags
  tag_specifications {
    resource_type = "volume"

    tags = merge(local.common_tags, {
      Name = "${var.project_name}-instance-volume"
    })
  }

  tag_specifications {
    resource_type = "network-interface"

    tags = merge(local.common_tags, {
      Name = "${var.project_name}-instance-nic"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-lt"
  })

  update_default_version = true
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = var.private_subnets
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  target_group_arns   = [var.target_group_arn]

  launch_template {
    name    = aws_launch_template.lt.name
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, { Name = "${var.project_name}-asg" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
