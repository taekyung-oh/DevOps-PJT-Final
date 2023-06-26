# securityhub 생성
resource "aws_securityhub_account" "team9_securityhub" {}



# resource "aws_securityhub_standards_subscription" "foundational" {
#     depends_on    = [aws_securityhub_account.team9_securityhub]
#     standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
# }

# resource "aws_securityhub_product_subscription" "config" {
#     depends_on  = [aws_securityhub_account.team9_securityhub]
#     product_arn = "arn:aws:securityhub:${data.aws_region.current.name}::product/aws/config"
# }

# resource "aws_securityhub_product_subscription" "guardduty" {
#     depends_on  = [aws_securityhub_account.team9_securityhub]
#     product_arn = "arn:aws:securityhub:${data.aws_region.current.name}::product/aws/guardduty"
# }

# resource "aws_securityhub_product_subscription" "inspector" {
#     depends_on  = [aws_securityhub_account.team9_securityhub]
#     product_arn = "arn:aws:securityhub:${data.aws_region.current.name}::product/aws/inspector"
# }

