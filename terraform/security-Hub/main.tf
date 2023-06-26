terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  # backend "s3" {
  #   bucket  = "bighead-project-tfstate"
  #   key     = "security-hub/terraform.tfstate"
  #   region  = "ap-northeast-2"
  #   encrypt = true
  # }

}

provider "aws" {
  region = "ap-northeast-2"
}