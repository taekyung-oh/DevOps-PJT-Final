
resource "aws_ssm_parameter" "ec2_asset_type" {
  name        = "/auto-tag/ec2/tag/bighead_AssetType"
  type        = "String"
  value       = "WAS"
}

resource "aws_ssm_parameter" "ec2_external_access" {
  name        = "/auto-tag/ec2/tag/bighead_ExternalAccess"
  type        = "String"
  value       = "Y"
}

resource "aws_ssm_parameter" "ec2_PIHandling" {
  name        = "/auto-tag/ec2/tag/bighead_PIHandling"
  type        = "String"
  value       = "N"
}

resource "aws_ssm_parameter" "ec2_Service_type" {
  name        = "/auto-tag/ec2/tag/bighead_ServiceType"
  type        = "String"
  value       = "EC2"
}

resource "aws_ssm_parameter" "s3_asset_type" {
  name        = "/auto-tag/s3/tag/bighead_AssetType"
  type        = "String"
  value       = "WEB"
}

resource "aws_ssm_parameter" "s3_external_access" {
  name        = "/auto-tag/s3/tag/bighead_ExternalAccess"
  type        = "String"
  value       = "Y"
}

resource "aws_ssm_parameter" "s3_PIHandling" {
  name        = "/auto-tag/s3/tag/bighead_PIHandling"
  type        = "String"
  value       = "N"
}

resource "aws_ssm_parameter" "s3_service_type" {
  name        = "/auto-tag/s3/tag/bighead_ServiceType"
  type        = "String"
  value       = "S3"
}