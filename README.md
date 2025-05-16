# Stockprice

Stock Price Cache Application 

![alt text](./page.png)


Stock Price  Application
This project is a fully containerized 3-tier stock price lookup system. It leverages FastAPI, Spring Boot, Redis, and a static frontend, deployed using AWS ECS Fargate, Terraform, Jenkins, and Docker. It also features end-to-end monitoring using Prometheus, Grafana, Node Exporter, and Alertmanager, provisioned with Ansible.

🔧 Architecture Overview
🧩 Services
Frontend (index.html)
Static web UI served via NGINX on an EC2 instance, where users input a stock ticker and date.

FastAPI (stock-api)
Handles API requests. It queries the cache (Spring Boot → Redis), and if not found, fetches mocked data and stores it in Redis.

Spring Boot (stock-cache)
Handles caching logic, communicating directly with Redis.

Redis
In-memory database for caching stock price data.

🏗️ Infrastructure & Deployment
🔨 Provisioning
Defined infrastructure as code using Terraform modules:
VPC, EC2, RDS, Security Groups, Load Balancer, Auto Scaling.

📦 Containerization
Each application layer has its own Dockerfile.
Docker images are pushed to Amazon ECR.

🚀 Orchestration
ECS Fargate is used for container orchestration.

Configured Task Definitions, Services, Load Balancing, and Networking.

🔄 CI/CD Pipeline
Jenkins (Dockerized) builds, pushes images, and triggers Terraform for infrastructure updates.

🔍 Monitoring & Observability
Monitoring is provisioned using Ansible and includes:

Prometheus: Pulls metrics from monitored targets.

Grafana: Visualizes metrics from Prometheus.

Node Exporter: Installed on EC2 instances to expose system metrics.

Alertmanager: Sends alerts based on Prometheus rules.

Monitoring stack is defined in Ansible playbooks and auto-deployed to target EC2 instances.

🔐 Security & Code Quality
Static Code Analysis:
Integrated SonarQube with Jenkins and configured Quality Gates.

Vulnerability Scanning:
Used Trivy to scan Docker images for security issues.

⚙️ Jenkins Configuration
Jenkins is containerized:

docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
Plugins Installed:

Temurin
SonarQube Scanner
OWASP Dependency-Check
Docker / Docker Pipeline
Amazon ECR

SonarQube Integration:

Generate token in SonarQube:
Administration → Security → Users → Generate Token

Add token in Jenkins Credentials.

Configure SonarQube server in Jenkins system configuration.

Add webhook in SonarQube pointing to:
http://<jenkins-url>/sonarqube-webhook/

🚀 Deployment Flow Summary
Jenkins builds Docker images.

Images are pushed to ECR.

Terraform applies ECS infrastructure updates.

ECS Fargate deploys containerized services.

Ansible provisions monitoring stack.

SonarQube and Trivy validate quality and security.