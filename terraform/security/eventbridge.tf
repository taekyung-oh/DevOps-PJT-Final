# eventbridge.tf

# # # # # EVNETBRIDGE RULE # # # # #
# 이벤트브릿지 룰 생성 후 cloudwatch와 연결
resource "aws_cloudwatch_event_rule" "ssm_automation_to_cloudwatch_event_rule" {
  name        = "ssm-automation-to-cloudwatch-event-rule"
  description = "config에서 ssm automation을 통해 자동화가 수행된 이후의 로그 기록을 위한 eventbridge 규칙"

  event_pattern = jsonencode({
    source = [
        "aws.ssm"
    ]
    detail-type = [
      "EC2 Automation Execution Status-change Notification"
    ]
  })
}

resource "aws_cloudwatch_event_target" "ssm_automation_log_group" {
  rule      = aws_cloudwatch_event_rule.ssm_automation_to_cloudwatch_event_rule.name
  target_id = "SSMAutomationToCloudWatch"
  arn       = aws_cloudwatch_log_group.ssm_automation_log_group.arn
}
