# aws 계정 id, 리전
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# ses email 인증
resource "aws_ses_email_identity" "example" {
  email = var.email
}