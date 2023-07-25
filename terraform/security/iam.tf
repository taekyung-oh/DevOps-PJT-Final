# iam.tf

# # # # # COMMON # # # # #
# aws account id 가져오기
data "aws_caller_identity" "current" {}

locals {
    account_id = data.aws_caller_identity.current.account_id
}

# # # # # CONFIG # # # # #
# config 활성화에 필요한 iam 설정
## (신뢰 정책 생성) assum policy
data "aws_iam_policy_document" "config_assume_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

## (신뢰 정책 할당) assume policy를 config role에 할당 
resource "aws_iam_role" "config_role" {
  name               = "BigheadConfigRole"
  assume_role_policy = data.aws_iam_policy_document.config_assume_policy.json
}

## (인라인 권한 정책 생성) config rule을 쓸 수 있는 정책 구문 생성
data "aws_iam_policy_document" "config_policy" {
  statement {
    effect    = "Allow"
    actions   = ["config:*"]
    resources = ["*"]
  }
}

## (인라인 권한 정책 할당) config 역할에 config 관련 정책 할당
resource "aws_iam_role_policy" "allow_config" {
  name   = "AllowConfig"
  role   = aws_iam_role.config_role.id
  policy = data.aws_iam_policy_document.config_policy.json
}

## (관리형 권한 정책 할당) arn:aws:iam::aws:policy/service-role/AWS_ConfigRole
resource "aws_iam_role_policy_attachment" "aws_config_role" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# config가 구성 기록을 s3에 쓰도록 허용하는 정책 부여
## (인라인 권한 정책 생성) config 역할에 s3 허용 정책 구문 생성
data "aws_iam_policy_document" "config_s3_policy" {
  statement {
    effect  = "Allow"
    actions = [
        "s3:*"
        ]
    resources = [
      aws_s3_bucket.config_s3_bucket.arn,
      "${aws_s3_bucket.config_s3_bucket.arn}/*"
    ]
  }
}

## (인라인 권한 정책 할당) config 역할에 s3 버킷 쓰기 정책 할당
resource "aws_iam_role_policy" "allow_config_to_write_s3" {
  name   = "AllowConfigToWriteS3"
  role   = aws_iam_role.config_role.id
  policy = data.aws_iam_policy_document.config_s3_policy.json
}

## (인라인 권한 정책 생성) s3 버킷에 config 권한 허용하는 인라인 정책 생성
## https://docs.aws.amazon.com/ko_kr/config/latest/developerguide/iamrole-permissions.html#iam-role-policies-S3-bucket
data "aws_iam_policy_document" "allow_access_from_config" {
  statement {
    sid = "AWSConfigBucketPermissionsCheck"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      aws_s3_bucket.config_s3_bucket.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"

      values = [
        "${local.account_id}"
      ]
    }
  }

  statement {
    sid = "AWSConfigBucketExistenceCheck"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.config_s3_bucket.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"

      values = [
        "${local.account_id}"
      ]
    }
  }

  statement {
    sid = "AWSConfigBucketDelivery"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.config_s3_bucket.arn}/AWSLogs/${local.account_id}/Config/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"

      values = [
        "${local.account_id}"
      ]
    }
  }
}

# # # # # CONFIG & SSM AUTOMATION # # # # #
# config automation role 생성
## (신뢰 정책 생성) assum policy
data "aws_iam_policy_document" "automation_assume_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ssm.amazonaws.com", "iam.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

## (신뢰 정책 할당) assume policy를 automation role에 할당 
resource "aws_iam_role" "automation_role" {
  name               = "BigheadAutomationRole"
  assume_role_policy = data.aws_iam_policy_document.automation_assume_policy.json
}

## (관리형 권한 정책 할당) arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole
resource "aws_iam_role_policy_attachment" "automation_role" {
  role   = aws_iam_role.automation_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

## (관리형 권한 정책 할당) arn:aws:iam::aws:policy/AmazonSSMAutomationApproverAccess
resource "aws_iam_role_policy_attachment" "automation_approver_access" {
  role   = aws_iam_role.automation_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMAutomationApproverAccess"
}

## (인라인 권한 정책 생성) automation 실행을 위해 필요한 api 권한을 부여하는 정책 생성
data "aws_iam_policy_document" "automation_inline_policy" {
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = [
                "s3:*",
                "ec2:*",
                "rds:*",
                "redshift:*",
                "guardduty:*",
                "iam:*"
    ]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = [
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

## (인라인 권한 정책 할당) automation 실행을 위해 필요한 인라인 정책 할당
resource "aws_iam_role_policy" "automation_inline_policy" {
  name        = "AutomationInlinePolicy"
  role        = aws_iam_role.automation_role.id
  policy      = data.aws_iam_policy_document.automation_inline_policy.json
}

# # # # # EVENT BRIDGE # # # # #
# cloudwatch에 로그를 쓸 수 있도록 iam 정책 생성 후 부여
data "aws_iam_policy_document" "eventbridge_log_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = ["arn:aws:logs:*"]
  }
}

resource "aws_cloudwatch_log_resource_policy" "eventbridge_log_policy" {
  policy_document = data.aws_iam_policy_document.eventbridge_log_policy.json
  policy_name = "eventbridge-log-policy"
}