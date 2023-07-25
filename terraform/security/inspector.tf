# inspector 생성
resource "aws_inspector2_enabler" "team9_inspector" {
  account_ids    = [data.aws_caller_identity.current.account_id]
  resource_types = ["ECR", "LAMBDA"]
}