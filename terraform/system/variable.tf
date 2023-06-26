data "terraform_remote_state" "monitoring" {
  backend = "s3"
  config = {
    bucket = "terraform-bighead-bucket"
    key    = "monitoring/terraform.tfstate"
    region = "ap-northeast-2"
  }  
}

variable "hosting_zone_id" {
  type        = string
  default = "Z04233653QF8Y15T1OVTE"
}

variable "vpc_id" {
  type        = string
  default = "vpc-0ee68d63db9894fcf"
}

variable "task_role_arn" {
  type        = string
  default = "arn:aws:iam::159088646233:role/ecsTaskRole"
}
variable "execution_role_arn" {
  type        = string
  default = "arn:aws:iam::159088646233:role/ecsTaskExecutionRole"
}

variable "AWS_PROMETHEUS_ENDPOINT" {
  type        = string
  default = "https://aps-workspaces.ap-northeast-2.amazonaws.com/workspaces/ws-e32a03c2-993b-4cce-a397-1e400b35752c/api/v1/remote_write"
}

variable "AOT_CONFIG_CONTENT_arn" {
  type        = string
  # default = "arn:aws:ssm:ap-northeast-2:159088646233:parameter/AOT_CONFIG_CONTENT"
  default = data.terraform_remote_state.monitoring.outputs.prometheus_write_url
}

variable "aws-otel-collector_image" {
  type        = string
  default = "public.ecr.aws/aws-observability/aws-otel-collector:v0.30.0"
}

variable "authentication_arn" {
  type        = string
  default = "arn:aws:acm:ap-northeast-2:159088646233:certificate/27046fd5-d667-4644-ba01-f67a846368d9"
}

