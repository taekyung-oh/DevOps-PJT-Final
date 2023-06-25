# config.tf

# # # # # CONFIG SET UP # # # # #
# config 레코더 설정
resource "aws_config_configuration_recorder" "config_recorder" {
  role_arn = aws_iam_role.config_role.arn
  recording_group {
    all_supported = true
  }
}

## config recorder 동작하도록 지정
resource "aws_config_configuration_recorder_status" "config_recorder_status" {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = var.config_on
  depends_on = [aws_config_delivery_channel.config_delivery_channel]
}

## Config S3 버킷 생성 및 config와 연결
resource "aws_s3_bucket" "config_s3_bucket" {
  bucket = "bighead-config-s3-bucket"
  force_destroy =  true # destroy 시 삭제되도록 수정
}

resource "aws_s3_bucket_policy" "allow_access_from_config" {
  bucket = aws_s3_bucket.config_s3_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_config.json
}

## config 구성 설정 기록할 s3 로그와 딜리버리 채널 연결
resource "aws_config_delivery_channel" "config_delivery_channel" {
  s3_bucket_name = aws_s3_bucket.config_s3_bucket.bucket
}

# # # # # CONFIG RULES # # # # # 
# 관리형 규칙들 추가
## 자동화 적용된 규칙들
resource "aws_config_config_rule" "s3-account-level-public-access-blocks" {
    name =  "s3-account-level-public-access-blocks"
    
    source {
        owner =  "AWS"
        source_identifier = "S3_ACCOUNT_LEVEL_PUBLIC_ACCESS_BLOCKS"
    }

    scope {
      compliance_resource_types = [ "AWS::S3::AccountPublicAccessBlock" ]
    }

    input_parameters = "{\"IgnorePublicAcls\":\"True\",\"BlockPublicPolicy\":\"True\",\"BlockPublicAcls\":\"True\",\"RestrictPublicBuckets\":\"True\"}"

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "guardduty-enabled-centralized" {
    name =  "guardduty-enabled-centralized"

    source {
        owner =  "AWS"
        source_identifier = "GUARDDUTY_ENABLED_CENTRALIZED"
    }

    maximum_execution_frequency = "TwentyFour_Hours"
    depends_on = [aws_config_configuration_recorder.config_recorder]
}


resource "aws_config_config_rule" "s3-bucket-public-write-prohibited" {
    name =  "s3-bucket-public-write-prohibited"
    
    source {
        owner =  "AWS"
        source_identifier = "S3_BUCKET_PUBLIC_WRITE_PROHIBITED"
    }

    scope {
      compliance_resource_types = [ "AWS::S3::Bucket" ]
    }

    maximum_execution_frequency = "TwentyFour_Hours"

    depends_on = [aws_config_configuration_recorder.config_recorder]
}
resource "aws_config_config_rule" "s3-bucket-public-read-prohibited" {
    name =  "s3-bucket-public-read-prohibited"
    
    source {
        owner =  "AWS"
        source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
    }
       scope {
      compliance_resource_types = [ "AWS::S3::Bucket" ]
    }

    maximum_execution_frequency = "TwentyFour_Hours"

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "rds-automatic-minor-version-upgrade-enabled" {
    name =  "rds-automatic-minor-version-upgrade-enabled"
    
    source {
        owner =  "AWS"
        source_identifier = "RDS_AUTOMATIC_MINOR_VERSION_UPGRADE_ENABLED"
    }
    scope {
      compliance_resource_types = [ "AWS::RDS::DBInstance" ]
    }

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "rds-instance-public-access-check" {
    name =  "rds-instance-public-access-check"

    source {
        owner =  "AWS"
        source_identifier = "RDS_INSTANCE_PUBLIC_ACCESS_CHECK"
    }
       scope {
      compliance_resource_types = [ "AWS::RDS::DBInstance" ]
    }

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "iam-policy-no-statements-with-admin-access" {
    name =  "iam-policy-no-statements-with-admin-access"

    source {
        owner =  "AWS"
        source_identifier = "IAM_POLICY_NO_STATEMENTS_WITH_ADMIN_ACCESS"
    }
    scope {
      compliance_resource_types = [ "AWS::IAM::Policy" ]
    }

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "restricted-common-ports" {
    name =  "restricted-common-ports"
    
    source {
        owner =  "AWS"
        source_identifier = "RESTRICTED_INCOMING_TRAFFIC"
    }

    scope {
      compliance_resource_types = ["AWS::EC2::SecurityGroup"]
    }

    input_parameters = "{\"blockedPort1\":\"20\",\"blockedPort2\":\"21\",\"blockedPort3\":\"3389\",\"blockedPort5\":\"4333\",\"blockedPort4\":\"3306\"}"
    depends_on = [aws_config_configuration_recorder.config_recorder]
}

## 자동화 적용되지 않은 규칙들
resource "aws_config_config_rule" "account-part-of-organizations" {
    name =  "account-part-of-organizations"
    source {
        owner =  "AWS"
        source_identifier = "ACCOUNT_PART_OF_ORGANIZATIONS"
    }

    maximum_execution_frequency = "TwentyFour_Hours"

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "cloudtrail-enabled" {
    name =  "cloudtrail-enabled"
    source {
        owner =  "AWS"
        source_identifier = "CLOUD_TRAIL_ENABLED"
    }

    maximum_execution_frequency = "TwentyFour_Hours"
    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "cloudwatch-alarm-action-check" {
    name =  "cloudwatch-alarm-action-check"
    source {
        owner =  "AWS"
        source_identifier = "CLOUDWATCH_ALARM_ACTION_CHECK"
    }
    input_parameters = "{\"alarmActionRequired\":\"true\",\"insufficientDataActionRequired\":\"true\",\"okActionRequired\":\"false\"}"
    
    scope {
      compliance_resource_types = [ "AWS::CloudWatch::Alarm" ]
    }

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "cloudwatch-alarm-action-enabled-check" {
    name =  "cloudwatch-alarm-action-enabled-check"
    
    source {
        owner =  "AWS"
        source_identifier = "CLOUDWATCH_ALARM_ACTION_ENABLED_CHECK"
    }
    scope {
      compliance_resource_types = [ "AWS::CloudWatch::Alarm" ]
    }

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "ecr-private-image-scanning-enabled" {
    name =  "ecr-private-image-scanning-enabled"

    source {
        owner =  "AWS"
        source_identifier = "ECR_PRIVATE_IMAGE_SCANNING_ENABLED"
    }

    maximum_execution_frequency = "TwentyFour_Hours"

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "ecs-containers-nonprivileged" {
    name =  "ecs-containers-nonprivileged"
    
    source {
        owner =  "AWS"
        source_identifier = "ECS_CONTAINERS_NONPRIVILEGED"
    }
       scope {
      compliance_resource_types = [ "AWS::ECS::TaskDefinition" ]
    }

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "ecs-containers-readonly-access" {
    name =  "ecs-containers-readonly-access"
    
    source {
        owner =  "AWS"
        source_identifier = "ECS_CONTAINERS_READONLY_ACCESS"
    }
    scope {
      compliance_resource_types = [ "AWS::ECS::TaskDefinition" ]
    }

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "ecs-task-definition-pid-mode-check" {
    name =  "ecs-task-definition-pid-mode-check"

    source {
        owner =  "AWS"
        source_identifier = "ECS_TASK_DEFINITION_PID_MODE_CHECK"
    }
    scope {
      compliance_resource_types = [ "AWS::ECS::TaskDefinition" ]
    }

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "iam-root-access-key-check" {
    name =  "iam-root-access-key-check"

    source {
        owner =  "AWS"
        source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
    }

    maximum_execution_frequency = "TwentyFour_Hours"
    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "lambda-function-public-access-prohibited" {
    name =  "lambda-function-public-access-prohibited"

    source {
        owner =  "AWS"
        source_identifier = "LAMBDA_FUNCTION_PUBLIC_ACCESS_PROHIBITED"
    }
    scope {
      compliance_resource_types = [ "AWS::Lambda::Function" ]
    }

    depends_on = [aws_config_configuration_recorder.config_recorder]
}
resource "aws_config_config_rule" "multi-region-cloudtrail-enabled" {
    name =  "multi-region-cloudtrail-enabled"
    
    source {
        owner =  "AWS"
        source_identifier = "MULTI_REGION_CLOUD_TRAIL_ENABLED"
    }

    maximum_execution_frequency = "TwentyFour_Hours"

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "rds-snapshots-public-prohibited" {
    name =  "rds-snapshots-public-prohibited"
    
    source {
        owner =  "AWS"
        source_identifier = "RDS_SNAPSHOTS_PUBLIC_PROHIBITED"
    }
    scope {
      compliance_resource_types = [ "AWS::RDS::DBSnapshot",
                    "AWS::RDS::DBClusterSnapshot" ]
    }
    depends_on = [aws_config_configuration_recorder.config_recorder]

}
resource "aws_config_config_rule" "root-account-hardware-mfa-enabled" {
    name =  "root-account-hardware-mfa-enabled"
    
    source {
        owner =  "AWS"
        source_identifier = "ROOT_ACCOUNT_HARDWARE_MFA_ENABLED"
    }

    maximum_execution_frequency = "TwentyFour_Hours"

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

resource "aws_config_config_rule" "ssm-document-not-public" {
    name =  "ssm-document-not-public"
    
    source {
        owner =  "AWS"
        source_identifier = "SSM_DOCUMENT_NOT_PUBLIC"
    }

    maximum_execution_frequency = "TwentyFour_Hours"

    depends_on = [aws_config_configuration_recorder.config_recorder]
}

# # # # # CONFIG AUTOMATION # # # # #
# 규칙 별로 automation 설정 
resource "aws_config_remediation_configuration" "s3-account-level-public-access-blocks" {
  config_rule_name = aws_config_config_rule.s3-account-level-public-access-blocks.name
  target_type      = "SSM_DOCUMENT"
  target_id        = "AWSConfigRemediation-ConfigureS3PublicAccessBlock"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.automation_role.arn
  }
  parameter {
    name           = "AccountId"
    resource_value = "RESOURCE_ID"
  }

  automatic                  = true
  maximum_automatic_attempts = 1
  retry_attempt_seconds      = 300
}

resource "aws_config_remediation_configuration" "guardduty-enabled-centralized" {
  config_rule_name = aws_config_config_rule.guardduty-enabled-centralized.name
  target_type      = "SSM_DOCUMENT"
  target_id = "AWSConfigRemediation-CreateGuardDutyDetector"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.automation_role.arn
  }

  automatic                  = true
  maximum_automatic_attempts = 1
  retry_attempt_seconds      = 300
}

resource "aws_config_remediation_configuration" "s3-bucket-public-write-prohibited" {
  config_rule_name = aws_config_config_rule.s3-bucket-public-write-prohibited.name
  target_type      = "SSM_DOCUMENT"
  target_id = "AWS-DisableS3BucketPublicReadWrite"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.automation_role.arn
  }
  parameter {
    name           = "S3BucketName"
    resource_value = "RESOURCE_ID"
  }

  automatic                  = true
  maximum_automatic_attempts = 1
  retry_attempt_seconds      = 300
}

resource "aws_config_remediation_configuration" "s3-bucket-public-read-prohibited" {
  config_rule_name = aws_config_config_rule.s3-bucket-public-read-prohibited.name
  target_type      = "SSM_DOCUMENT"
  target_id = "AWS-DisableS3BucketPublicReadWrite"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.automation_role.arn
  }
  parameter {
    name           = "S3BucketName"
    resource_value = "RESOURCE_ID"
  }

  automatic                  = true
  maximum_automatic_attempts = 1
  retry_attempt_seconds      = 300
}

resource "aws_config_remediation_configuration" "rds-automatic-minor-version-upgrade-enabled" {
  config_rule_name = aws_config_config_rule.rds-automatic-minor-version-upgrade-enabled.name
  target_type      = "SSM_DOCUMENT"
  target_id = "AWSConfigRemediation-EnableMinorVersionUpgradeOnRDSDBInstance"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.automation_role.arn
  }
  parameter {
    name           = "DbiResourceId"
    resource_value = "RESOURCE_ID"
  }

  automatic                  = true
  maximum_automatic_attempts = 1
  retry_attempt_seconds      = 300
}
resource "aws_config_remediation_configuration" "rds-instance-public-access-check" {
  config_rule_name = aws_config_config_rule.rds-instance-public-access-check.name
  target_type      = "SSM_DOCUMENT"
  target_id = "AWSConfigRemediation-DisablePublicAccessToRDSInstance"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.automation_role.arn
  }
  parameter {
    name           = "DbiResourceId"
    resource_value = "RESOURCE_ID"
  }

  automatic                  = true
  maximum_automatic_attempts = 1
  retry_attempt_seconds      = 300
}

resource "aws_config_remediation_configuration" "iam-policy-no-statements-with-admin-access" {
  config_rule_name = aws_config_config_rule.iam-policy-no-statements-with-admin-access.name
  target_type      = "SSM_DOCUMENT"
  target_id = "AWSConfigRemediation-ReplaceIAMInlinePolicy"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.automation_role.arn
  }
  parameter {
    name           = "ResourceId"
    resource_value = "RESOURCE_ID"
  }

  automatic                  = true
  maximum_automatic_attempts = 1
  retry_attempt_seconds      = 300
}

resource "aws_config_remediation_configuration" "estricted-common-ports" {
  config_rule_name = aws_config_config_rule.restricted-common-ports.name
  target_type      = "SSM_DOCUMENT"
  target_id = "Custom-DisablePublicAccessForSecurityGroup"

  parameter {
    name         = "AutomationAssumeRole"
    static_value = aws_iam_role.automation_role.arn
  }
  parameter {
    name           = "GroupId"
    resource_value = "RESOURCE_ID"
  }

  automatic                  = true
  maximum_automatic_attempts = 1
  retry_attempt_seconds      = 300
  
  depends_on = [aws_ssm_document.custom_disable_public_access_for_security_group]
}
