terraform {
  # Location of tag-management state file
  backend "s3" {
    bucket  = "terraform-bighead-bucket"
    key     = "tag-management/terraform.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-northeast-2"
}