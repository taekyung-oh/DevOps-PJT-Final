# securityhub 로그 그룹 생성
resource "aws_cloudwatch_log_group" "securityhub_logs" {
    name = "securityhub_logs"

}

# resource "aws_cloudwatch_log_subscription_filter" "securityhub_logs" {
#     name            = "securityhub_logs_subscription_filter"
#     log_group_name  = aws_cloudwatch_log_group.securityhub_logs.name
#     filter_pattern  = ""
#     destination_arn = aws_lambda_function.SlackEmail-lambda.arn
# }