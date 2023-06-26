output "prometheus_write_url" {
  description = "Prometheus Workspace Write URL"
  value       = "${aws_prometheus_workspace.prometheus_workspace.prometheus_endpoint}/api/v1/remote_write"
}
