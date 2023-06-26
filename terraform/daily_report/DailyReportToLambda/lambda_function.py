
import json
import logging
import urllib3
import urllib.request
import boto3
import botocore
import os
from base64 import b64decode
from datetime import datetime


ssm_client = boto3.client("ssm")

logging.getLogger().setLevel(logging.INFO)
log = logging.getLogger(__name__)

#이메일 보내기 
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
                'Data': f"[ {datetime.today().strftime('%Y-%m-%d')} 성능 보고 ]"
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

#API KEY 가져오기 
def get_ssm_parameter():
    path_string = "/grafana/api"
    if path_string:
        try:
            get_parameter_response = ssm_client.get_parameters_by_path(
                Path=path_string, Recursive=True, WithDecryption=True
            )
            if get_parameter_response.get("Parameters"):
                for parameter in get_parameter_response.get("Parameters"):
                    path_components = parameter["Name"].split("/")
                    tag_key = path_components[-1]
                    if tag_key == "key" :
                        return parameter.get("Value")
                    
            else:
                return None
        except botocore.exceptions.ClientError as error:
            log.error(f"Boto3 API returned error: {error}")
            return None
    else:
        return None


def lambda_handler(event, context):
    http = urllib3.PoolManager()
    
    resultData=[]
    
    headerData={"Authorization": f"Bearer {get_ssm_parameter()}"
                , "Accept":"application/json"
                ,"Content-Type":"application/json" }
    
    #태그 bighead로 설정되어 있는 대시보드 조회 
    req = http.request('GET', "https://g-668c36f6ac.grafana-workspace.ap-northeast-2.amazonaws.com/api/search?tag=bighead"
                            , headers=headerData)
                            
    #byte로 되어있는 데이터 json으로 수정 
    data = json.loads(req.data.decode('utf8'))
    
    resultData.append(f">*[ {datetime.today().strftime('%Y-%m-%d')} 성능 보고 ]*")
    
    for item in data:
        
        #스냅샷 이름 설정 
        fileName = f"{item.get('title')}_{datetime.today().strftime('%Y-%m-%d')}"
        
        url = f"https://g-668c36f6ac.grafana-workspace.ap-northeast-2.amazonaws.com/api/dashboards/uid/{item.get('uid')}"
        
        #스냅샷 생성할 대시보드 데이터 가져오기 
        req = http.request('GET', url
                                , headers=headerData)
        #data = req.data
        #response_message = req.data.decode('utf8')
        data2 = json.loads(req.data.decode('utf8'))
        
        url = 'https://g-668c36f6ac.grafana-workspace.ap-northeast-2.amazonaws.com/api/snapshots'
        
        #스냅샷 만들 대시보드 데이터 값 가공 
        data3 = {"name" : fileName,"dashboard" : data2.get("dashboard")}
        
        #JSON 형식에서 byte 형식으로 변경하여 스냅샷 생성 
        req = http.request('POST', url, body=json.dumps(data3), headers=headerData, retries = False)
        
        
        #스냅샷 생성된 데이터 name, url 보관  
        #resultData.append({"name": fileName, "url": json.loads(req.data).get("url")})
        urlData=json.loads(req.data.decode('utf8')).get("url")
        resultData.append(f">*{fileName[0:fileName.find('_')]}* \n>URL : { urlData }")
    
    #message = f">*[ {datetime.today().strftime('%Y-%m-%d')} 성능 보고 ]*\n"
    
    #for item in resultData:
    #    f">{item.get('name')} URL : {item.get('url')}\n"
    
    print(resultData);
    print("\n".join(resultData))
    message = "\n".join(resultData)
    #message = "AAAAA"
    post_slack(message)
    send_email(message)
    
