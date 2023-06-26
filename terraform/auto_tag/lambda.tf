data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


data "aws_iam_policy_document" "auto-tag-iam-policy-document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "auto-tag-lam-role-policy" {
  name = "auto-tag-lam-role-policy"
  role = aws_iam_role.auto-tag-role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "iam:ListRoleTags",
                "ssm:GetParametersByPath",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:parameter/*",
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/AutoTagingToLambda:*",
                "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:DeleteObjectTagging",
                "s3:ListBucketMultipartUploads",
                "ec2:CreateTags",
                "s3:DeleteStorageLensConfigurationTagging",
                "s3:ListBucketVersions",
                "s3:ReplicateTags",
                "s3:PutStorageLensConfigurationTagging",
                "s3:PutObjectVersionTagging",
                "s3:PutJobTagging",
                "s3:ListBucket",
                "s3:DeleteObjectVersionTagging",
                "logs:CreateLogGroup",
                "s3:ListMultipartUploadParts",
                "s3:DeleteJobTagging",
                "s3:PutBucketTagging",
                "s3:PutObjectTagging"
            ],
            "Resource": [
                "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:instance/*",
                "arn:aws:ec2:*:${data.aws_caller_identity.current.account_id}:volume/*",
                "arn:aws:s3:::*",
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
            ]
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "s3:ListBucket",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/resource-auto-tagger",
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/resource-auto-tagger:log-stream:*",
                "arn:aws:s3:::*"
            ]
        },
        {
            "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "logs:DescribeLogStreams",
                "logs:GetLogEvents",
                "s3:DeleteObject"
            ],
            "Resource": [
                "arn:aws:s3:::*",
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/resource-auto-tagger",
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/resource-auto-tagger:log-stream:*"
            ]
        },
        {
            "Sid": "VisualEditor4",
            "Effect": "Allow",
            "Action": [
                "s3:ListStorageLensConfigurations",
                "s3:ListAccessPointsForObjectLambda",
                "s3:ListAllMyBuckets",
                "s3:ListAccessPoints",
                "s3:ListJobs",
                "s3:ListMultiRegionAccessPoints"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor5",
            "Effect": "Allow",
            "Action": [
                "s3:ListStorageLensConfigurations",
                "s3:ListAccessPointsForObjectLambda",
                "s3:ListAllMyBuckets",
                "s3:ListAccessPoints",
                "s3:ListJobs",
                "s3:ListMultiRegionAccessPoints"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Sid": "VisualEditor6",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstances",
                "ec2:DescribeVolumes"
            ],
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Sid": "VisualEditor7",
            "Effect": "Allow",
            "Action": "cloudwatch:PutMetricData",
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Sid": "VisualEditor8",
            "Effect": "Allow",
            "Action": "logs:DescribeLogGroups",
            "Resource": [
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/resource-auto-tagger",
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/resource-auto-tagger:log-stream:*"
            ]
        }
    ]
})
}

resource "aws_iam_role" "auto-tag-role" {
  name               = "auto-tag-role"
  assume_role_policy = data.aws_iam_policy_document.auto-tag-iam-policy-document.json
}


data "archive_file" "auto_tag_package" {
  type        = "zip"
  source_file = "./AutoTagingToLambda/lambda_function.py"
  output_path = "AutoTagingToLambda.zip"
}


resource "aws_lambda_permission" "auto-tag-ec2-Lambda" {
  statement_id  = "AutoTagingEc2Permissions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.AutoTagingToLambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto_taging_ec2_to_lambda_event_rule.arn
}

resource "aws_lambda_permission" "auto-tag-s3-Lambda" {
  statement_id  = "AutoTagingS3Permissions"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.AutoTagingToLambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.auto_taging_s3_to_lambda_event_rule.arn
}


# Create the Lambda function Resource

resource "aws_lambda_function" "AutoTagingToLambda" {
  function_name    = "AutoTagingToLambda"
  filename         = "AutoTagingToLambda.zip"
  source_code_hash = data.archive_file.auto_tag_package.output_base64sha256
  role             = aws_iam_role.auto-tag-role.arn
  runtime          = "python3.9"
  handler          = "lambda_function.lambda_handler"
  timeout          = 10

}

resource "aws_cloudwatch_log_group" "lambda_function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.AutoTagingToLambda.function_name}"
  retention_in_days = 14   # 로그의 expire 기간
}
