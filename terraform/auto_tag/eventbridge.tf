# eventbridge.tf

# # # # # EVNETBRIDGE RULE # # # # #
# 이벤트브릿지 룰 생성 후 Lambda와 연결(EC2)
resource "aws_cloudwatch_event_rule" "auto_taging_ec2_to_lambda_event_rule" {
  name        = "auto_taging_ec2_to_lambda_event_rule"
  description = "자동 태그 EC2 생성 시 발생"

  event_pattern = jsonencode({
    source = [
        "aws.ec2"
    ],
    detail-type= ["AWS API Call via CloudTrail"],
    detail= {
      "eventSource": ["ec2.amazonaws.com"],
      "eventName": ["RunInstances"]
    }
  })
}


resource "aws_cloudwatch_event_target" "auto_taging_ec2_to_lambda_event_rule_target" {

  rule      = aws_cloudwatch_event_rule.auto_taging_ec2_to_lambda_event_rule.name
  target_id = "auto_taging_ec2_to_lambda_event_rule_target"
  arn       = aws_lambda_function.AutoTagingToLambda.arn
}


# 이벤트브릿지 룰 생성 후 Lambda와 연결(S3)
resource "aws_cloudwatch_event_rule" "auto_taging_s3_to_lambda_event_rule" {
  name        = "auto_taging_s3_to_lambda_event_rule"
  description = "자동 태그 S3 생성 시 발생"

  event_pattern = jsonencode({
    source = [
        "aws.s3"
    ],
    detail-type= ["AWS API Call via CloudTrail"],
    detail= {
      "eventSource": ["s3.amazonaws.com"],
      "eventName": ["CreateBucket"]
    }
  })
}


resource "aws_cloudwatch_event_target" "auto_taging_s3_event_target" {

  rule      = aws_cloudwatch_event_rule.auto_taging_s3_to_lambda_event_rule.name
  target_id = "auto_taging_s3_event_target"
  arn       = aws_lambda_function.AutoTagingToLambda.arn
}
