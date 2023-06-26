terraform {
  # Location of monitoring state file
  backend "s3" {
    bucket  = "terraform-bighead-bucket"
    key     = "monitoring/terraform.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    grafana = {
      source  = "grafana/grafana"
      version = "1.30.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-northeast-2"
}

provider "grafana" {
  url  = "https://${aws_grafana_workspace.grafana_workspace.endpoint}"
  auth = aws_grafana_workspace_api_key.grafana_api_key.key
}