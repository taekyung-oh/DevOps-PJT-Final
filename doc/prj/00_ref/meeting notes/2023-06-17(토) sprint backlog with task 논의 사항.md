# 기존 시스템 구축
1. ECS에 web/was 배포
2. Github에 코드가 push되면 자동으로 code pipeline, code build, code deploy 과정 수행
3. 레거시 시스템 데모 시연을 위해 alb, ecr, ecs fargate, rds, s3 구축
4. Alb에 waf를 활용해 네트워크 보안 강화
5. IaC(Terraform) CI/CD 
6. (Optional) lambda CI/CD 

# 자산 구분시스템
## 자동 태깅
1. Parameter store에 자산 분류 태그 생성
    - **자산 분류 naming convetion 회의 필요**
2. 기존 시스템 구축 과정에서 인스턴스가 생성되어 cloudtrail에 로그를 eventbridge의 트리거로 태깅 lambda가 동작하도록 구성 
3. (Optional) 필요한 경우 cloudtrail에서 cloudwatch로 로그를 전달하도록 구성
4. 태깅 lambda에서 parameter store를 활용해 리소스 태깅 작업 수행
## 수동 태깅
1. Resource group과 tag editor를 사용해 리소스 분류 작업 수행

# 자산 점검 프로세스
1. 태깅된 자산의 분류에 따라 inspector로 실시간으로 cve를 점검해 취약점이 발견되면 security hub로 전달하도록 구성
2. 태깅된 자산의 분류에 따라 config의 실시간으로 구성 규칙을 선별해 cce를 점검하고 취약점이 발견되면 security hub로 전달하도록 구성
4. Guard duty를 활용해 실시간으로 지능 위협 취약점 탐지 후 취약점이 발견되면 security hub로 전달하도록 구성
6. 취약점이 발생하면 Security hub에서 event bridge를 통해 cloudwatch와 SNS로 전달
7. (Optional) SNS lambda로 전달 후 SNS lambda에서 SNS로 전달
8. SNS에 전달된 이벤트 메시지를 email lambda로 전달 후 Email lambda에서 취약점 보고서 형식으로 가공 후 email 및 slack으로 전달하도록 코드 작성
9. Config에서 자동 수정이 가능한 일부 취약점의 경우 system manager를 활용해 자동 수정 진행

## TBD
- 취약점이 예를 들어 CVE에서만 발견된 경우에도 security hub에서 통합된 기록을 통해 모든 취약점에 대한 보고가 이루어지는가? ->  **security hub는 취약점 등이 발견되었을 경우에만 로그가 적재됨**
- 만일 config에서 자동 조치가 가능한 부분/불가한 부분이 있을 경우 이를 구분해서 보고하는가? 자동으로 조치된 취약점은 실시간으로 알리는가? -> **정 안되면 중복 보고**
- Sns lambda의 역할? -> **현재로서는 불필요 판단, 추후 필요시 추가**

# 모니터링
1. 기존 구축된 시스템에 adot 컨테이너 이미지를 사이드카 컨테이너를 동작시켜서 리소스들의 메트릭, 트레이스 수집하도록 구성
2. 메트릭은 amp, 트레이스는 x-ray로 전달되도록 구성
3. Grafana는 cloudwatch에 전달된 취약점 로그와, amp의 메트릭, x-ray의 트레이스를 데이터 소스로 사용하며 쿼리를 통해 시각화 대시보드 생성
5. eventbridge를 통해 정기적으로 스케쥴링된 email lambda를 트리거
7. Email lambda는 수집한 로그, 메트릭, 트레이스릉 가공해 일별 점검 리포트를 생성하며, 이때 grafana의 report api를 통해 시각화된 보고서 생성. 
8. 생성된 보고서를 email 및 slack으로 전송
# **⚠️ aws grafana에서 사이드바 enterprise 라이센 상에서 전환 절대 누르면 안 됨! workspace 내에서 enterprise upgrade**
![Monosnap Zoom 회의 - 소회의실 9 2023-06-19 10-32-02](https://github.com/cs-devops-bootcamp/devops-04-Final-Team9/assets/54361848/9714f0aa-eb8e-458f-96e2-9ead2d8c5f62)


## TBD
- 정기적으로 sns 트리거하는 방법? -> **SNS를 이벤트 브릿지로 대체**
- 그라파나의 쿼리는 어떻게 선별할지? -> **개발할 사람이 선별하거나 그라파나 커뮤니티 템플릿 사용**