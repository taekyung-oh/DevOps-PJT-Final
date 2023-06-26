# provider.tf

provider "aws" {
  region = var.region
}

backend "s3" {
  bucket  = "bighead-project-tfstate"
  key     = "auto_tag/terraform.tfstate"
  region  = "ap-northeast-2"
  encrypt = true
}
