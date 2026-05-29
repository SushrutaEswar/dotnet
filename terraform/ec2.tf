resource "aws_launch_template" "lt" {
  name_prefix   = "dotnet-lt"
  image_id      = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(file("userdata.sh"))
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity = 2
  max_size         = 2
  min_size         = 2

  vpc_zone_identifier = [
    aws_subnet.public1.id,
    aws_subnet.public2.id
  ]

  target_group_arns = [
    aws_lb_target_group.blue.arn
  ]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }
}