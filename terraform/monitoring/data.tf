data "terraform_remote_state" "system" {
  backend = "s3"
  config = {
    bucket = "terraform-bighead-bucket"
    key    = "system/terraform.tfstate"
    region = "ap-northeast-2"
  }  
}

data "aws_caller_identity" "current" {}

data "aws_ssoadmin_instances" "ssoadmin_instances" {}

data "aws_iam_policy_document" "grafana_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["grafana.amazonaws.com"]
    }
  }
}