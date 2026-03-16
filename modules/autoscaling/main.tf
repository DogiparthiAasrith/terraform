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
  name_prefix = "${var.project_name}-lt-"
  
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro" # Often required in restricted cloud environments

  vpc_security_group_ids = [var.security_group_id]

  # Enforce IMDSv2 (Standard security policy requirement)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # Encrypted volumes are often required by Service Control Policies (SCPs)
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      encrypted   = true
    }
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello from Terraform ASG!" > index.html
              nohup python3 -m http.server 80 &
              EOF
  )

  # Instance tags in LT are checked during the RunInstances call
  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${var.project_name}-${var.environment}-instance"
    })
  }

  # Ensure the LT itself has all mandatory tags
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-lt"
  })

  update_default_version = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                = "${var.project_name}-${var.environment}-asg"
  vpc_zone_identifier = var.private_subnets
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  target_group_arns   = [var.target_group_arn]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Default"
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, { Name = "${var.project_name}-${var.environment}-asg" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
