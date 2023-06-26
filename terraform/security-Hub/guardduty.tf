# guardduty 생성
resource "aws_guardduty_detector" "team9_guardduty" {
    enable = true

        datasources {
        s3_logs {
            enable = true
        }
        kubernetes {
            audit_logs {
                enable = false
            }
        }
        malware_protection {
            scan_ec2_instance_with_findings {
                ebs_volumes {
                enable = false
                }
            }
        }
    }
}