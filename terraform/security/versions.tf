# version.tf
# terraform 리소스는 언더바(_), aws 리소스는 대시(-)

terraform {
  cloud {
    organization = "devops04-bighead"

    workspaces {
      name = "bighead"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.5.0"
    }
  }
}