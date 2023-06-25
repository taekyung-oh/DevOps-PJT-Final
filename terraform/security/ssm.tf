# ssm.tf

# # # # # SSM DOCUMENT # # # # # 
# 자동화 문서 생성
resource "aws_ssm_document" "custom_disable_public_access_for_security_group" {
  name            = "Custom-DisablePublicAccessForSecurityGroup"
  document_format = "YAML"
  document_type   = "Automation"

  content = <<DOC
description: |-
  Disable some ports opened to IP address specified, or to all addresses if no address is specified. Similar to the RevokeSecurityGroupIngress (https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_RevokeSecurityGroupIngress.html) API, the security group must have existing rules specifically on ports in order for ingress to be disabled.
  (https://docs.aws.amazon.com/ko_kr/securityhub/latest/userguide/ec2-controls.html#ec2-19)
schemaVersion: '0.3'
assumeRole: '{{ AutomationAssumeRole }}'
parameters:
  GroupId:
    type: String
    description: (Required) Security Group ID
    allowedPattern: '^([s][g]\-)([0-9a-f]){1,}$'
  IpAddressToBlock:
    type: String
    description: '(Optional) Additional Ipv4 or Ipv6 address to block access from (ex:1.2.3.4/32)'
    allowedPattern: '(^$)|^((25[0-5]|(2[0-4]\d|[0-1]?\d?\d)(\.(25[0-5]|2[0-4]\d|[0-1]?\d?\d)){3})|(^((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?)::((?:[0-9A-Fa-f]{1,4}(?::[0-9A-Fa-f]{1,4})*)?))|(^(?:[0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}))\/(25[0-5]|2[0-4]\d|[0-1]?\d?\d)$'
    default: ''
  AutomationAssumeRole:
    type: String
    description: (Optional) The ARN of the role that allows Automation to perform the actions on your behalf.
    default: ''
mainSteps:
  - name: DisableFTPDataFromIpV4
    action: 'aws:executeAwsApi'
    inputs:
      Service: ec2
      Api: RevokeSecurityGroupIngress
      GroupId: '{{GroupId}}'
      IpPermissions:
        - IpProtocol: tcp
          FromPort: 20
          ToPort: 20
          IpRanges:
            - CidrIp: 0.0.0.0/0
    onFailure: Continue
  - name: DisableFTPDataFromIpV6
    action: 'aws:executeAwsApi'
    inputs:
      Service: ec2
      Api: RevokeSecurityGroupIngress
      GroupId: '{{GroupId}}'
      IpPermissions:
        - IpProtocol: tcp
          FromPort: 20
          ToPort: 20
          Ipv6Ranges:
            - CidrIpv6: '::/0'
    onFailure: Continue
  - name: DisableFTPControlFromIpV4
    action: 'aws:executeAwsApi'
    inputs:
      Api: RevokeSecurityGroupIngress
      Service: ec2
      GroupId: '{{GroupId}}'
      IpPermissions:
        - IpProtocol: tcp
          FromPort: 21
          ToPort: 21
          IpRanges:
            - CidrIp: 0.0.0.0/0
    onFailure: Continue
  - name: DisableFTPControlFromIpV6
    action: 'aws:executeAwsApi'
    inputs:
      Api: RevokeSecurityGroupIngress
      Service: ec2
      GroupId: '{{GroupId}}'
      IpPermissions:
        - IpProtocol: tcp
          FromPort: 21
          ToPort: 21
          Ipv6Ranges:
            - CidrIpv6: '::/0'
    onFailure: Continue
  - name: DisableMYSQLFromIpV4
    action: 'aws:executeAwsApi'
    inputs:
      Service: ec2
      Api: RevokeSecurityGroupIngress
      GroupId: '{{GroupId}}'
      IpPermissions:
        - IpProtocol: tcp
          FromPort: 3306
          ToPort: 3306
          IpRanges:
            - CidrIp: 0.0.0.0/0
    onFailure: Continue
  - name: DisableRDPFromIpV4
    action: 'aws:executeAwsApi'
    inputs:
      Service: ec2
      Api: RevokeSecurityGroupIngress
      GroupId: '{{GroupId}}'
      IpPermissions:
        - IpProtocol: tcp
          FromPort: 3389
          ToPort: 3389
          IpRanges:
            - CidrIp: 0.0.0.0/0
    onFailure: Continue
  - name: DisableRDPFromIpV6
    action: 'aws:executeAwsApi'
    inputs:
      Service: ec2
      Api: RevokeSecurityGroupIngress
      GroupId: '{{GroupId}}'
      IpPermissions:
        - IpProtocol: tcp
          FromPort: 3389
          ToPort: 3389
          Ipv6Ranges:
            - CidrIpv6: '::/0'
    isEnd: false
    onFailure: Continue
  - name: DisableMYSQLFromIpV6
    action: 'aws:executeAwsApi'
    inputs:
      Api: RevokeSecurityGroupIngress
      Service: ec2
      GroupId: '{{GroupId}}'
      IpPermissions:
        - IpProtocol: tcp
          FromPort: 3306
          ToPort: 3306
          Ipv6Ranges:
            - CidrIpv6: '::/0'
    description: ''
    onFailure: Continue
    isEnd: false
  - name: EndAutomation
    action: 'aws:executeScript'
    inputs:
      Runtime: python3.6
      Handler: script_handler
      Script: |-
        def script_handler(events, context):
          print(events)
          return {'message': events }
    isEnd: true
    onFailure: Continue
DOC
}