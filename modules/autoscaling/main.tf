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