# aws 계정 id, 리전
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# lambda iam role
resource "aws_iam_role" "iam_for_SlackEmail_lambda" {
    name               = "iam_for_SlackEmail_lambda"
    assume_role_policy = data.aws_iam_policy_document.SlackEmail_lambda_role.json
}

data "aws_iam_policy_document" "SlackEmail_lambda_role" {
    statement {
        effect = "Allow"

        principals {
            type        = "Service"
            identifiers = ["lambda.amazonaws.com"]
        }

        actions = ["sts:AssumeRole"]
    }
}

# lambda CloudWatchFullAccess
resource "aws_iam_role_policy_attachment" "iam_for_SlackEmail_lambda_attachments" {
    role       = aws_iam_role.iam_for_SlackEmail_lambda.name

    policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

# lambda CloudWatchLogsFullAccess
resource "aws_iam_role_policy_attachment" "iam_for_SlackEmail_lambda_attachments_2" {
    role       = aws_iam_role.iam_for_SlackEmail_lambda.name

    policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# lambda CloudWatchEventsFullAccess
resource "aws_iam_role_policy_attachment" "iam_for_SlackEmail_lambda_attachments_3" {
    role       = aws_iam_role.iam_for_SlackEmail_lambda.name

    policy_arn = "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
}

#lambda Eamil policy 생성
resource "aws_iam_policy" "lambda_send_email_policy" {
  name        = "lambda_send_email_policy"
  description = "Policy for Lambda to send emails"
  policy      = data.aws_iam_policy_document.AllowLambdaToSendEmail.json
}

# lambda SlackEmail
resource "aws_iam_role_policy_attachment" "iam_for_SlackEmail_lambda_attachments_4" {
    role       = aws_iam_role.iam_for_SlackEmail_lambda.name
    policy_arn = aws_iam_policy.lambda_send_email_policy.arn
}

# lambda slackEmail policy data
data "aws_iam_policy_document" "AllowLambdaToSendEmail" {
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
    ]
    resources = ["*"]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail",
    ]
    resources = ["arn:aws:ses:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:identity/bighead@gyuroot.com"]
  }
}

# lambda function
resource "aws_lambda_function" "SlackEmail_lambda" {
    filename      = "./lambda_function/SlackEmail-lambda.zip"

    function_name = "SlackEmail_lambda"

    handler       = "SlackEmail-lambda.lambda_handler"
    timeout       = "3"
    role          = aws_iam_role.iam_for_SlackEmail_lambda.arn
    runtime       = "python3.10"

    layers        = ["arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:layer:python_request_layer:12"]


    environment {
        variables = {
            RECIPIENT_EMAIL     = var.RECIPIENT_EMAIL
            RECIPIENT_EMAILS    = var.RECIPIENT_EMAILS
            SENDER_EMAIL        = var.SENDER_EMAIL
            SLACK_URL           = var.SLACK_URL
        }
    }
}

# lambda cloudwatch permission
resource "aws_lambda_permission" "logging" {
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.SlackEmail_lambda.function_name
    principal     = "logs.${data.aws_region.current.name}.amazonaws.com"
    source_arn    = "${aws_cloudwatch_log_group.securityhub_logs.arn}:*"
}

resource "aws_cloudwatch_log_subscription_filter" "logging" {
    depends_on      = [aws_lambda_permission.logging]
    destination_arn = aws_lambda_function.SlackEmail_lambda.arn
    filter_pattern  = ""
    log_group_name  = aws_cloudwatch_log_group.securityhub_logs.name
    name            = "logging_securityhub_logs"
}


