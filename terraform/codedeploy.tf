resource "aws_codedeploy_app" "app" {
  name             = "dotnet-app"
  compute_platform = "Server"
}

resource "aws_iam_role" "codedeploy_role" {

  name = "codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "codedeploy.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_admin" {

  role       = aws_iam_role.codedeploy_role.name

  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_codedeploy_deployment_group" "dg" {

  depends_on = [
    aws_lb.alb,
    aws_lb_listener.front_end,
    aws_lb_target_group.blue,
    aws_lb_target_group.green
  ]

  app_name              = aws_codedeploy_app.app.name

  deployment_group_name = "dotnet-dg"

  service_role_arn = aws_iam_role.codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  autoscaling_groups = [
    aws_autoscaling_group.asg.name
  ]

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {

    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  load_balancer_info {

    target_group_info {
      name = aws_lb_target_group.blue.name
    }

    target_group_info {
      name = aws_lb_target_group.green.name
    }
  }

  auto_rollback_configuration {

    enabled = true

    events = [
      "DEPLOYMENT_FAILURE"
    ]
  }
}