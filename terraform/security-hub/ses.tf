# ses email 인증
resource "aws_ses_email_identity" "email_identity" {
  email = var.email
}