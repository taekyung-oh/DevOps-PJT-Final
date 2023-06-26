data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "daily-report-policy-document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "daily-report-iam-role-policy" {
  name = "daily-report-iam-role-policy"
  role = aws_iam_role.daily-report-role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "ssm:GetParametersByPath",
            "Resource": "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/*"
        },
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/DailyReportToLambda:*"
            ]
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "ses:SendRawEmail"
            ],
            "Resource": "*"
        },
        {
            "Sid": "",
            "Effect": "Allow",
            "Action": [
                "ses:SendEmail",
                "ses:SendRawEmail"
            ],
            "Resource": "arn:aws:ses:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identity/bighead@gyuroot.com"
        }
    ]
})
}

resource "aws_iam_role" "daily-report-role" {
  name               = "daily-report-role"
  assume_role_policy = data.aws_iam_policy_document.daily-report-policy-document.json
}


data "archive_file" "daily_report_package" {
  type        = "zip"
  source_file = "./DailyReportToLambda/lambda_function.py"
  output_path = "DailyReportToLambda.zip"
}

resource "aws_lambda_permission" "daily-report-Lambda" {
  statement_id  = "DailyReportPermissions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.DailyReportToLambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_scheduler_schedule.daily_report_schedule.arn
}


# Create the Lambda function Resource

resource "aws_lambda_function" "DailyReportToLambda" {
  function_name    = "DailyReportToLambda"
  filename         = "DailyReportToLambda.zip"
  source_code_hash = data.archive_file.daily_report_package.output_base64sha256
  role             = aws_iam_role.daily-report-role.arn
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  timeout          = 10

  environment {
    variables = {
      RECIPIENT_EMAIL   = "kwm7502@gmail.com"
      RECIPIENT_EMAILS  = "bighead@gyuroot.com"
      SENDER_EMAIL  = "bighead@gyuroot.com"
      SLACK_URL  = "https://hooks.slack.com/services/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"
    }
  }

}

resource "aws_cloudwatch_log_group" "daily_report_lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.DailyReportToLambda.function_name}"
  retention_in_days = 14   # 로그의 expire 기간
}
