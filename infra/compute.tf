data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["137112412989"] # Amazon
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

locals {
  user_data = templatefile("${path.module}/userdata.sh", {
    PROJECT_NAME = var.project_name
  })
}

resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(local.user_data)

  network_interfaces {
    security_groups             = [aws_security_group.ec2_sg.id]
    associate_public_ip_address = false
  }

  lifecycle { create_before_destroy = true }
  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project_name}-instance" }
  }
}

resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-asg"
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = [for s in aws_subnet.private : s.id]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 90

  capacity_rebalance = true

  tag {
    key                 = "Name"
    value               = "${var.project_name}-instance"
    propagate_at_launch = true
  }

  depends_on = [aws_lb_listener.http]
}
