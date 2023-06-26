
resource "aws_ssm_parameter" "grafana_api" {
  name        = "/grafana/api/key"
  type        = "SecureString"
  value       = "eyJrIjoiNXBZR09ycTIxS2pOQVBZRkM1eUdEQnczVWdEQ05XUzkiLCJuIjoiZ3JhZmFuYS1yZXBvcnQiLCJpZCI6MX0="
}