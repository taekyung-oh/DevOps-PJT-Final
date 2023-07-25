resource "aws_ssm_parameter" "adot_config_content" {
  name        = "bighead-adot_config_content"
  type        = "String"
  value       = <<PARAMETER
extensions:
  health_check:
  sigv4auth:
    region: $AWS_REGION

receivers:
  otlp:
    protocols:
      grpc:
        endpoint: 0.0.0.0:4317
  awsecscontainermetrics:

processors:
  batch/traces:
    timeout: 30s
    send_batch_size: 50
  batch/metrics:
    timeout: 60s
  resourcedetection:
    detectors:
      - env      
      - ecs      
  filter:
    metrics:
      include:
        match_type: strict
        metric_names:
          - ecs.task.memory.reserved
          - ecs.task.memory.utilized
          - ecs.task.cpu.reserved
          - ecs.task.cpu.utilized
          - ecs.task.network.rate.rx
          - ecs.task.network.rate.tx
          - ecs.task.storage.read_bytes
          - ecs.task.storage.write_bytes

exporters:
  awsxray:
  prometheusremotewrite:
    endpoint: $AWS_PROMETHEUS_ENDPOINT
    auth:
      authenticator: sigv4auth
    resource_to_telemetry_conversion:
      enabled: true

service:
  pipelines:
    traces:
      receivers: [otlp]
      processors: [resourcedetection, batch/traces]
      exporters: [awsxray]
    metrics/application:
      receivers: [otlp]
      processors: [resourcedetection, batch/metrics]
      exporters: [prometheusremotewrite]
    metrics:
      receivers: [awsecscontainermetrics]
      processors: [filter]
      exporters: [prometheusremotewrite]

  extensions: [health_check, sigv4auth]
PARAMETER
}
