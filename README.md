# 자산 관리 시스템 
## Architecture
![Final_project-STEP_01 drawio](https://github.com/cs-devops-bootcamp/devops-04-Final-Team9/assets/54361848/632c05b2-0199-48f9-9607-37fdca0f9b88)

## User Story
현재의 시스템의 로그 뿐 만 아니라 시스템 취약점 점검을 자동화하고 점검 결과를 통합하여 관리할 수 있도록 하는 자산관리 파이프라인 시스템을 구축하여야 합니다.

### 기능 요구사항
1. 자산구분 시스템: 자산 분류 기준에 따라 수립된 정의 및 리소스에 적절한 태크 설정
   * 자산 분류 기준 태그 예시
     - 환경(env): DEV, PROD
     - 자산 종류: Web Server, WAS, 수강생 데이터 베이스, 유어클래스 강의자료
     - 개인정보 취급 여부: Y/N
     - 소유자: DevOps
3. 정보 자산 점검
   * CCE(Common Configuration Enuymeration) 취약점: 사용자에게 권한 이상의 동작을 허용하는 등의 시스템 설정 상의 취약점
   * CVE(Common Vulnerabilities and Exposure) 취약점: 컴퓨터 하드웨어 또는 소프트웨어 결함이나 체계 설계상의 취약점
3. 모니터링 및 알람
   * 취약성 점검 결과 알림
   * 일별 점검 결과 리포트

### 인프라 요구사항
- 시스템 전반에 가용성, 내결함성, 확장성, 보안성이 고려된 서비스들이 포함되어야 합니다.
- 하나 이상의 컴퓨팅 유닛에 대한 CI/CD 파이프라인이 구성되어야합니다.
- 시스템 메트릭 또는 저장된 데이터에 대한 하나 이상의 시각화된 모니터링 시스템이 구축되어야합니다.

## Product Backlog
### 📍 CI/CD 파이프라인
ECS에 배포되어 있는 WEB/WAS 컨테이너 소스를 깃허브를 통해 관리 및 CI/CD를 수행하기 위해 AWS CodePipeline, CodeBuild, CodeDeploy 서비스를 이용해야 합니다.
정보 자산 시스템 데모 시연을 위해 ALB, ECR, ECS fargate, RDS, S3를 사용합니다.

### 📍 자산 구분 시스템 프로세스
#### 자동 태깅
유저가 인스턴스를 생성하면 Cloud Tail 은 리소스 생성 API 이벤트를 로깅하고, CloudWatch 이벤트 규칙은 이벤트 생성 시 모니터링되고 트리거하기 위해 사용합니다. CloudWatch 이벤트 규칙은 적용 가능한 이벤트를 감지한 다음 Lambda 함수를 호출하여 리소스에 태그를 지정하고, Lambda는 Parameter Store에서 필요한 태그를 검색하고 새 리소스에 태그를 지정하기 위해 사용합니다.
#### 수동 태깅
유저가 생성한 인스턴스를 resource group으로 묶은 뒤 tag editor로 태그를 수정하기 위해 사용합니다.

### 📍 자산 점검 프로세스
#### CVE 및 CCE 점검
CVE 취약점은 AWS Inspector로, CCE 취약점은 AWS Config로 점검하며, 추가적으로 Guard Duty로 확인된 취약점은 Security hub로 전달됩니다. 
#### 보안 강화 프로세스
WAF, Guard Duty로 추가적인 보안을 강화합니다.

### 📍 알림
#### 실시간 취약성 점검 결과 알림 (실시간 발생 시) 
Security Hub에서 Event Bridge Rule을 통해 CloudWatch와 Lambda로 전달합니다. CloudWatch에서는 발견된 취약성에 대한 정보를, Lambda는 실시간으로 발견된 취약성에 대한 알람을 보내기 위해 사용합니다. Lambda는 SNS로 취약점에 대한 정보를 전달하며, SNS는 보안팀에게 e-mail로 취약점을 보고하고, slack 보고를 위한 lambda가 동작합니다. 추가적으로 System Manager의 자동화 기능으로 수정이 가능한 취약점은 자동으로 수정합니다.
#### 일별 점검 결과 리포트
일일 점검 결과는 AMP의 alerting rules로 정기적으로 실행되며 SNS로 전달된 후 lambda를 통해 가공합니다.  lambda에서는 전달된 성능 정보와 grafana enterprise의 리포트 API 기능을 통해  보안팀 및 DevOps 팀에 메일과 slack으로  전송합니다.

### 📍 시각화된 모니터링
#### Metrics & Traces 시각화
ADOT를 사용해 AMP, X-Ray에 수집된 Metrics&Traces를 Amazon Managed Grafana에서 쿼리하여 시각화합니다.
#### 취약점 로그 시각화
Security Hub에 통합된 취약점 로그를 CloudWatch로 전송하고, Amazon Managed Grafana에서 쿼리하여 시각화합니다.

### 📍 비용 관리 프로세스
예상 비용 초과시 Budget 서비스를 이용해 SNS로 전달하고 이메일 알림을 통해 Devops 및 구매팀으로 알림을 전달합니다.
