# eventbridge.tf

# # # # # EVNETBRIDGE RULE # # # # #
# 이벤트브릿지 룰 생성 후 cloudwatch와 연결
#resource "aws_cloudwatch_event_rule" "daily_report_event_rule" {
#    name = "daily_report_event_rule"
#    schedule_expression = "cron(0 0 * 6 ? 2023)"
#    start_date = 2023-06-26T01:00:00Z
#    end_date = 2023-06-30T01:00:00Z
#}


resource "aws_iam_role" "schedule-role" {
  name               = "schedule-role"
  assume_role_policy = data.aws_iam_policy_document.schedule-policy-document.json
}

data "aws_iam_policy_document" "schedule-policy-document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_scheduler_schedule" "daily_report_schedule" {
  name       = "daily_report_schedule"
  group_name = aws_scheduler_schedule_group.example.name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "cron(0 21 * 6 ? 2023)"

  end_date = "2023-06-30T01:00:00Z"
  schedule_expression_timezone = "Asia/Seoul"

  target {
    arn      = aws_lambda_function.DailyReportToLambda.arn
    role_arn = aws_iam_role.schedule-role.arn
  }
}

resource "aws_scheduler_schedule_group" "example" {
  name = "my-schedule-group"
}
