resource "aws_identitystore_user" "sso_user" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.ssoadmin_instances.identity_store_ids)[0]

  display_name = "bighead"
  user_name    = "bighead"

  name {
    given_name  = "head"
    family_name = "big"
  }

  emails {
    value = "bighead@gyuroot.com"
  }
}

resource "aws_iam_role" "grafana_role" {
  name                = "grafana-role"
  assume_role_policy  = data.aws_iam_policy_document.grafana_assume_role_policy.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"
                        ,"arn:aws:iam::aws:policy/service-role/AmazonGrafanaCloudWatchAccess"
                        , aws_iam_policy.grafana_prometheus_policy.arn]
}

resource "aws_iam_policy" "grafana_prometheus_policy" {
  name = "grafana-prometheus-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"        
        Action   = [
            "aps:ListWorkspaces",
            "aps:DescribeWorkspace",
            "aps:QueryMetrics",
            "aps:GetLabels",
            "aps:GetSeries",
            "aps:GetMetricMetadata"
        ]
        Resource = aws_prometheus_workspace.prometheus_workspace.arn
      },
    ]
  })
}