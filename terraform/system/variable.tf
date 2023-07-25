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

variable "aws_prometheus_endpoint" {
  type        = string
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

