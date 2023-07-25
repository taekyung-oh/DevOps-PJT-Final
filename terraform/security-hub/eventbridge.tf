#eventbridge 생성
resource "aws_cloudwatch_event_rule" "securityhub_cloudwatch_log" {
    name            = "securityhub_cloudwatch_log"
    event_pattern   = jsonencode({
        #로그 전달 필터
        "source" : ["aws.securityhub"], "detail": { "findings": { "ProductName": [{ "exists": true }], "Severity": { "Label": ["CRITICAL", "HIGH", "MEDIUM"]} } }
    })
}

# 로그 그룹으로 연결
resource "aws_cloudwatch_event_target" "securityhub_logs" {
    rule = aws_cloudwatch_event_rule.securityhub_cloudwatch_log.name
    arn  = aws_cloudwatch_log_group.securityhub_logs.arn
}