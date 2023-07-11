# 자산 관리 시스템 
## Architecture
<img width="864" alt="아키텍처" src="https://github.com/taekyung-oh/DevOps-PJT-Final/assets/126674247/604730ce-8520-412c-b324-02ce9c937f28">


## Observability
![image](https://github.com/cs-devops-bootcamp/devops-04-Final-Team9/assets/126463472/7498e4ee-ef46-4c3c-8321-5a044d3caaea)
<br><br>
## Environment
<img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=GitHub&logoColor=white"/><img src="https://img.shields.io/badge/GithubActions-2088FF?style=for-the-badge&logo=GithubActions&logoColor=white"/><img src="https://img.shields.io/badge/AmazonAWS-232F3E?style=for-the-badge&logo=AmazonAWS&logoColor=white"/><img src="https://img.shields.io/badge/Prometheus-E6522C?style=for-the-badge&logo=Prometheus&logoColor=white"/><img src="https://img.shields.io/badge/Grafana-F46800?style=for-the-badge&logo=Grafana&logoColor=white"/><img src="https://img.shields.io/badge/Gmail-EA4335?style=for-the-badge&logo=Gmail&logoColor=white"/><img src="https://img.shields.io/badge/Slack-4A154B?style=for-the-badge&logo=Slack&logoColor=white"/><img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=Python&logoColor=white"/><img src="https://img.shields.io/badge/JavaScript-F7DF1E?style=for-the-badge&logo=JavaScript&logoColor=white"/><img src="https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=Terraform&logoColor=white"/><img src="https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=Windows&logoColor=white"/><img src="https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=Ubuntu&logoColor=white"/>



[![Amazon S3](https://img.shields.io/badge/Amazon%20S3-Cloud%20Storage-orange?style=flat-square&logo=amazon-s3)](https://aws.amazon.com/s3/)
[![Amazon RDS](https://img.shields.io/badge/Amazon%20RDS-Managed%20Database-orange?style=flat-square&logo=amazon-rds)](https://aws.amazon.com/rds/)
[![AWS Lambda](https://img.shields.io/badge/AWS%20Lambda-Serverless-orange?style=flat-square&logo=amazon-lambda)](https://aws.amazon.com/lambda/)
[![AWS Fargate](https://img.shields.io/badge/AWS%20Fargate-Serverless%20Containers-orange?style=flat-square&logo=aws-fargate)](https://aws.amazon.com/fargate/)
[![Amazon ECS](https://img.shields.io/badge/Amazon%20ECS-Container%20Service-orange?style=flat-square&logo=amazon-ecs)](https://aws.amazon.com/ecs/)
[![AWS CloudWatch](https://img.shields.io/badge/AWS%20CloudWatch-Monitoring%20and%20Observability-orange?style=flat-square&logo=amazon-cloudwatch)](https://aws.amazon.com/cloudwatch/)
[![AWS WAF](https://img.shields.io/badge/AWS%20WAF-Web%20Application%20Firewall-orange?style=flat-square&logo=amazon-waf)](https://aws.amazon.com/waf/)
[![AWS Security Hub](https://img.shields.io/badge/AWS%20Security%20Hub-Security%20Monitoring-orange?style=flat-square&logo=amazon-security-hub)](https://aws.amazon.com/security-hub/)
[![AWS Inspector](https://img.shields.io/badge/AWS%20Inspector-Vulnerability%20Assessment-orange?style=flat-square&logo=amazon-inspector)](https://aws.amazon.com/inspector/)
[![AWS X-Ray](https://img.shields.io/badge/AWS%20X--Ray-Tracing%20%26%20Analytics-orange?style=flat-square&logo=amazon-xray)](https://aws.amazon.com/xray/)
[![AWS Config](https://img.shields.io/badge/AWS%20Config-Resource%20Compliance%20%26%20Audit-orange?style=flat-square&logo=amazon-config)](https://aws.amazon.com/config/)
[![AWS Systems Manager](https://img.shields.io/badge/AWS%20Systems%20Manager-Operational%20Data%20Collection-orange?style=flat-square&logo=amazon-systems-manager)](https://aws.amazon.com/systems-manager/)
[![AWS CloudTrail](https://img.shields.io/badge/AWS%20CloudTrail-Audit%20%26%20Compliance-orange?style=flat-square&logo=amazon-cloudtrail)](https://aws.amazon.com/cloudtrail/)
[![Amazon Route 53](https://img.shields.io/badge/Amazon%20Route%2053-DNS%20Management-orange?style=flat-square&logo=amazon-route53)](https://aws.amazon.com/route53/)
[![OpenTelemetry](https://img.shields.io/badge/OpenTelemetry-Observability-yellow?style=flat-square&logo=open-telemetry)](https://opentelemetry.io)
[![Prometheus](https://img.shields.io/badge/Prometheus-Monitoring-yellow?style=flat-square&logo=prometheus)](https://prometheus.io)
[![AWS Resource Groups](https://img.shields.io/badge/AWS%20Resource%20Groups-Resource%20Organization-orange?style=flat-square&logo=amazon-aws)](https://aws.amazon.com/resource-groups/)


<br><br>
## Project Description
### User Story
✅ 자산 관리 시스템을 도입하게 된다면 이 시스템을 어떻게 운영 및 보안 계획을 수립할것인가
많은 기업들이 각종 시스템과 IT 자산을 효율적으로 관리할 필요성이 커지고 있으며 이를 효율적으로 관리하기 위한 최적의 관리방법으로 EAM(Enterprise Asset Management), ITAM(IT Asset Management) 등 여러가지 관리 시스템을 운용을 하고 있습니다.

하지만 미흡한 보안 정책 및 절차로 인한 피해사례가 있었으며 그에 따른 해결방안으로 아래의 기사를 참고하여 중요성을 알게 되었습니다.

> **“자산관리 플랫폼으로 공격자 침투 가능성 낮춰야”**
> 
> 국내 주요 기업과 기관을 공격했던 매스스캔 랜섬웨어는 취약점이 있는 노출된 DB 서버를 파괴하면서 피해조직의 서비스를 중단시켰다.
> ……
> 포괄적인 IT 자산 인벤토리는 만들고 유지 관리하기 어렵다. 인벤토리 구축을 위한 기존의 많은 방법은 시간이 많이 걸리고 단편적이며 최신 상태를 유지하기 어렵다.
> 따라서 공격 표면 영역을 정의할 때 데이터 수집 및 상관 관계를 자동화하고, 부담스러운 인력 리소스 투입을 최소화하며, 실시간 결과를 위해 지속적으로 실행할 수 있는 사이버 보안 자산 관리 플랫폼을 사용하고 있는지 확인할 수 있는 방안을 강구해야 한다.
> 출처 : 데이터넷 – 2023.02.03

따라서 프로젝트의 목표는 이렇게 됩니다.

1. 자산 분류 기준에 따라 수립된 정의 및 리소스에 적절한 Tag 설정
   - 자산이 많아질수록 관리의 복잡도를 완화하기 위해 각 리소스를 식별할 수 있어야 하며 그룹화 할 수 있어야 합니다.
2. 정보 자산 점검
   - MITRE 에서 제공하는 보안 기준인 CCE 및 CVE 취약점을 점검하고 위협을 제거 할 수 있어야 합니다.
3. 모니터링 및 알람
   - 리소스에서 Metric과 Log를 수집하고 시각화 할 수 있어야 합니다.
   - 수집한 데이터로 예기치 못한 상황의 알람과 매일 점검한후의 보고서를 확인 할 수 있어야 합니다.
4. 자동화
   - 단순 반복적인 작업은 자동화 할 수 있어야 하며 인프라 전반의 CI/CD 파이프라인이 구성되어야 합니다.
<br><br>
## How-To 가이드
### 📍 CI/CD 파이프라인
GitHub을 통해 ECS에 배포되어 있는 Application 및 IaC 소스 코드를 관리하며, 배포 자동화를 수행하기 위해 GitHub Actions를 사용합니다.<br>
관리 대상 시스템 구축을 위해 Route53, ALB, ECR, ECS Fargate, RDS, S3를 사용합니다.
<br><br>
### 📍 자산 구분 시스템 프로세스
#### 자동 태깅
AWS 사용자가 리소스를 생성 및 수정하면 CloudTrail은 API 이벤트를 로깅하고, EventBridge를 통해 Lambda를 호출합니다.<br>
호출된 Lambda함수는 SSM Parameter Store에 저장되어 있는 태그 관련 정보를 읽어, 리소스에 적절한 태그를 태깅합니다.
#### 수동 태깅
Resource Group을 이용해 모든 리소스를 태그 단위로 관리하고, 태그 추가, 수정 및 삭제가 필요할 시 Tag Editor에서 태깅 작업을 수행합니다.
<br><br>
### 📍 자산 점검 프로세스
#### CVE 점검
AWS Inspector를 이용해 WEB/WAS 컨테이너 이미지의 결함이나 체계, 설계상의 취약점을 점검하며, 점검 내용을 Security Hub로 통합합니다.
#### CCE 점검
AWS Config를 이용해 AWS 리소스의 설정상의 취약점을 점검하며, 점검 내용을 Security Hub로 통합합니다.<br>
자동 조치가 가능한 취약점은 SystemManager Automarion을 이용하여 조치합니다.
<br><br>
### 📍 Observability
#### Metric & Trace 수집
ECS 각 서비스에 OpenTelemetry Collector 사이드카 컨테이너를 배포합니다.<br>
Collector는 WEB, WAS 컨테이너 및 어플리케이션으로부터 Metric과 Trace를 수집하며,<br>
Metric은 AMP(Amazon Managed Prometheus), Trace는 X-Ray로 전송합니다.
#### 시각화
AMG(Amazon Managed Grafana)를 이용해 그라파나 워크스페이스를 관리합니다.<br>
그라파나에서 AMP, X-Ray, CloudWatch를 쿼리하여 시각화 대시보드를 구성합니다.
<br><br>
### 📍 알림
#### 자산 점검 알림
Security Hub에 통합된 점검 내용과 SystemManager Automarion으로 자동 조치한 내용을 CloudWatch로 통합하고, Lambda 함수의 트리거로 사용해 Slack 및 Email로 전송합니다.
#### 일별 리포트
매일 아침 그라파나 대시보드의 스냅샷을 생성하고, 해당 URL을 Slack 및 Email로 전송합니다.
<br><br>
### 📍 비용 관리 프로세스
Budget 서비스를 이용해 비용 임계치를 설정하고, 예상 비용 초과시 Email을 전송합니다.
