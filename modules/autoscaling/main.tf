data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow HTTP inbound from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  ingress {
    description     = "Allow SSH from EICE security group"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.eice_sg_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    CreatedBy = "Aasrith"
  }
}

resource "aws_launch_template" "lt" {
  name_prefix   = "${var.project_name}-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello from Terraform ASG!" > index.html
              nohup python3 -m http.server 80 &
              EOF
  )

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
