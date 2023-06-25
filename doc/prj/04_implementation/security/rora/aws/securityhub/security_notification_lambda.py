import gzip
import json
import base64
import urllib.request
import datetime
import pytz
import re
import os
from base64 import b64decode
import boto3

def send_email(message):
    CHARSET = "UTF-8"

    ses_client = boto3.client('ses', region_name='ap-northeast-2')
    sender_email = os.environ['SENDER_EMAIL']
    recipient_emails = os.environ['RECIPIENT_EMAILS'].split(',')
    message = message.replace("\n>", "</p><p>").replace(">*","<h1>").replace("*</p>","</h1>").replace(" `", "<span style=\"color:red;font-weight:bold;\">").replace("`", "</span>")

    response = ses_client.send_email(
        Source=sender_email,
        Destination={
            'ToAddresses': recipient_emails
        },
        Message={
            'Subject': {
                'Data': "[🚨SECURITY NOTIFICATION🚨]"
            },
            'Body': {
                'Html': {
                    'Charset': CHARSET,
                    'Data': message
                }
            }
        }
    )

# slack에 메시지 전송
def post_slack(argStr):
    message = argStr
    send_data = {
        "text": message,
    }
    send_text = json.dumps(send_data)

    slack_url = os.environ['SLACK_URL']
    request = urllib.request.Request(
        slack_url, 
        data=send_text.encode('utf-8'), 
    )

    with urllib.request.urlopen(request) as response:
        message = response.read()        


def lambda_handler(event, context):
    if 'awslogs' in event:
        cw_data = event['awslogs']['data']

        # base64 디코딩
        compressed_payload = base64.b64decode(cw_data)
        uncompressed_payload = gzip.decompress(compressed_payload).decode('utf-8')
        payload = json.loads(uncompressed_payload)
    
        log_events = payload['logEvents']
        for log_event in log_events:
            #print(f'[LogEvent]: {log_event}')    
        
            messages = log_event['message']
            if messages is not None:
                #print(messages)
                messages = json.loads(messages)
            
            detail = messages['detail']
            if detail is not None:
                #print(detail)
                findings = detail['findings']
            if findings is not None:
                #print(findings)
                
                for finding in findings:
                    # 보고 구성 항목
                    ## 주요 항목
                    types = finding['Types'][0]
                    title = finding['Title']
                    severity_label = finding['Severity']['Label']
                    severity_score = finding['Severity']['Normalized']

                    targets = ""
                    for resource in finding['Resources']:
                        # 리소스 마스킹처리
                        pat = re.compile("(\d{12})")
                        target = pat.sub("************", resource['Id'])
                        targets += f"{target} "

                    ## 세부 항목
                    # 시간 한국 시간으로 변경
                    dt = datetime.datetime.strptime(finding['CreatedAt'][:19], '%Y-%m-%dT%H:%M:%S')
                    KST = pytz.timezone("Asia/Seoul")
                    time = dt.astimezone(KST)

                    productName = f"{finding['CompanyName']} {finding['ProductName']}"
                    compliance_status = finding['Compliance']['Status']
                    record_state = finding['RecordState']
                    workflow_status = finding['Workflow']['Status']
                    description = finding['Description']

                    # slack 메시지 생성        
                    message = f">*[🚨SECURITY NOTIFICATION🚨]*\n>취약점명: `{title}`\n>심각도 수준: `{severity_label}({severity_score}점)`\n>발생 리소스: `{target}`\n>취약점 유형: `{types}`\n>\n>현지 발생 시각: {time} \n> 탐지 서비스: {productName}\n>준수 상태: {compliance_status}\n>활성화 상태: {record_state}\n>생성 상태: {workflow_status}\n>상세 내용: {description}"

                    #print(message)        
                    post_slack(message)
                    send_email(message)
    else:
        print("'awslogs' key not found in event data")                
                
