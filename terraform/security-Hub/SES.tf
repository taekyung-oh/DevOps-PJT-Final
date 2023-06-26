# ses email 인증
resource "aws_ses_email_identity" "example" {
  email = var.email
}