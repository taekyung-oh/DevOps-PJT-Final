# provider.tf

provider "aws" {
  region = var.region
}

backend "s3" {
  bucket  = "bighead-project-tfstate"
  key     = "daily_report/terraform.tfstate"
  region  = "ap-northeast-2"
  encrypt = true
}
