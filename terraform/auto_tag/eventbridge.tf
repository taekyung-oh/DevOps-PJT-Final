# eventbridge.tf

# # # # # EVNETBRIDGE RULE # # # # #
# 이벤트브릿지 룰 생성 후 cloudwatch와 연결
resource "aws_cloudwatch_event_rule" "auto_taging_ec2_to_lambda_event_rule" {
  name        = "auto_taging_ec2_to_lambda_event_rule"
  description = "config에서 ssm automation을 통해 자동화가 수행된 이후의 로그 기록을 위한 eventbridge 규칙"

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


resource "aws_cloudwatch_event_rule" "auto_taging_s3_to_lambda_event_rule" {
  name        = "auto_taging_s3_to_lambda_event_rule"
  description = "config에서 ssm automation을 통해 자동화가 수행된 이후의 로그 기록을 위한 eventbridge 규칙"

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