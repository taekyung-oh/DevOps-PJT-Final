resource "aws_grafana_workspace" "grafana_workspace" {
  name                     = "bighead-workspace"
  account_access_type      = "CURRENT_ACCOUNT"
  authentication_providers = ["AWS_SSO"]
  permission_type          = "SERVICE_MANAGED"
  data_sources             = ["CLOUDWATCH", "PROMETHEUS", "XRAY"]
  role_arn                 = aws_iam_role.grafana_role.arn
}

resource "aws_grafana_role_association" "grafana_role_association" {
  role         = "ADMIN"
  user_ids     = [aws_identitystore_user.sso_user.user_id]
  workspace_id = aws_grafana_workspace.grafana_workspace.id
}

resource "aws_grafana_workspace_api_key" "grafana_api_key" {
  key_name        = "admin-key"
  key_role        = "ADMIN"
  seconds_to_live = 3600
  workspace_id    = aws_grafana_workspace.grafana_workspace.id
}

resource "grafana_data_source" "prometheus" {
  type = "prometheus"
  name = "prometheus-datasource"
  url  = aws_prometheus_workspace.prometheus_workspace.prometheus_endpoint

  json_data {
    default_region = "ap-northeast-2"
    sigv4_auth = true
    sigv4_auth_type = "workspace-iam-role"
    sigv4_region = "ap-northeast-2"
  }
}

# resource "grafana_data_source" "xray" {
#   type = "X-Ray"
#   name = "xray-datasource"

#   json_data {
#     default_region = "ap-northeast-2"
#     auth_type = "workspace-iam-role"
#   }
# }

resource "grafana_data_source" "cloudwatch" {
  type = "cloudwatch"
  name = "cloudwatch-datasource"

  json_data {
    default_region = "ap-northeast-2"
    auth_type = "workspace-iam-role"
  }
}

resource "grafana_folder" "folder" {
  title = "bighead"
}

resource "grafana_dashboard" "prometheus-dashboard" {
  config_json = templatefile("${path.module}/dashboard/prometheus.tftpl",
                             { data_sources_aps = grafana_data_source.prometheus.uid,
                               data_sources_cw = grafana_data_source.cloudwatch.uid,
                               cluster_arn = data.terraform_remote_state.system.outputs.ecs-cluster-arn,
                               account_id =  data.aws_caller_identity.current.account_id })
  folder = grafana_folder.folder.id
  overwrite = true
}

resource "grafana_dashboard" "xray-dashboard" {
  config_json = templatefile("${path.module}/dashboard/xray.tftpl",
                             { data_sources_xray = "example",
                               account_id =  data.aws_caller_identity.current.account_id })
  folder = grafana_folder.folder.id
  overwrite = true
}

resource "grafana_dashboard" "security-dashboard" {
  config_json = templatefile("${path.module}/dashboard/security.tftpl",
                             { data_sources_cw = grafana_data_source.cloudwatch.uid,
                               account_id =  data.aws_caller_identity.current.account_id })
  folder = grafana_folder.folder.id
  overwrite = true
}