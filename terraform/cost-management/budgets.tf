# 버짓 생성
resource "aws_budgets_budget" "FinalProject_team9" {
  name              = "FinalProject_team9_budget"
  budget_type       = "COST"
  limit_amount      = "130" #할당 요금
  limit_unit        = "USD"
  time_period_end   = "2023-06-30_00:00" #기간 종료
  time_period_start = "2023-06-17_00:00" #기간 시작
  time_unit         = "MONTHLY" #월별

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = var.SUBSCRIBER_EMAIL_ADDRESSES
  }
}