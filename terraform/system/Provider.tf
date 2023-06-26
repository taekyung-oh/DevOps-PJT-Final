terraform {
  backend "s3" {
    bucket  = "terraform-bighead-bucket"
    key     = "system/terraform.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.49.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-2"
  default_tags {
    tags = {
      deployMethod = "Terraform"
    }
  }
}
