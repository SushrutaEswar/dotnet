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
resource "aws_codedeploy_deployment_group" "dg" {

  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "dotnet-dg"
  service_role_arn      = aws_iam_role.codedeploy_role.arn

  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  autoscaling_groups = [
    aws_autoscaling_group.asg.name
  ]

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }
}