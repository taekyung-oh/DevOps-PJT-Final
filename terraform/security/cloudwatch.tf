# cloudwatch.tf

# 자동화 실행 내역 기록할 로그 그룹 생성
resource "aws_cloudwatch_log_group" "ssm_automation_log_group" {
  name              = "/aws/events/ssm/automation"
  retention_in_days = 14   # 로그의 expire 기간
}

# automation 로그 그룹 아웃풋
output "ssm_automation_log_output" {
        value = "aws_cloudwatch_log_group.ssm_automation_log_group.arn"
}