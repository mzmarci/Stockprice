# Stockprice

Stock Price Cache Application  [ By Techbleat ]

![alt text](./page.png)


This project consists of a **FastAPI** service that fetches stock prices from a **Spring Boot** application, which caches the data in **Redis**. The services are orchestrated using **Docker Compose**. Additionally, there is a **web interface** (`index.html`) that allows users to interact with the application through a simple UI.

## Services Overview

1. **FastAPI** (`stock-api`): This service exposes an API that allows clients to get stock prices by providing a ticker symbol and date. It first checks the cache (Redis) via the Spring Boot application, and if the data is not available, it fetches the data externally (mocked in this case) and stores it in Redis.
   
2. **Spring Boot** (`stock-cache`): This service provides caching capabilities, storing and retrieving stock prices in Redis.

3. **Redis** (`redis`): The cache store where stock prices are stored temporarily.

4. **Web Frontend** (`index.html`): A simple web page that allows users to input a stock ticker and date to retrieve stock price information and  see the result.

# The project Architecture
1. Frontend: Deployed using nginx on an Ec2 server
2. Application Layer:this is deployed using ecs
3: Backend Layer: this is deployed using

## Methodology
a: created modules for ec2,vpc,rds,security,load balancer, auto scaling
b: for each of the layer a dockerfile was created
Define ECS tasks and services for each containerized component.
Use ECS Fargate for serverless container management.
Configure load balancing, service discovery, and networking.
Deployment Flow

Jenkins builds and pushes images.
Terraform applies ECS infrastructure updates.
ECS Fargate runs and manages the services.


## Deloying security on the application
made use of sonarqube and trivy

installed my jenkins using a docker conatiner, to get the password
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
on my jenkins, i installed some pipeline which are
temurin
SonarQube Scanner
OWASP Dependency-Check
Docker,docker pipeline, docker build
amazon ecr

##  configuring jenkins pipeline
go to tools - click on add sonarqube scanner
N.B - to integarte sonarqube to jenkins we need the sonarqube tokens which is ususally gotten from sonarqube.
To get the token, go to sonarqube, click on administration, then click on security, click on users, click on token, click on update token, enetr any name of ur choice then click on generate, a token will be generated.

Go back to jenkins, click on credentials, then insert the sonarqube token.

We need to add quality gate to our jenkins pipeline, to do that go to your sonarqube,, click on administration, click on configuration, click on webhooks [the webhooks tells us if the projct is looking fine and if we can continue with it], click on create, click on jenkins, paste your jenkins url/sonarqube-webhook/

Go back to jenkins, click on system configuration, search for sonarqube, on the sonarqube installation, input any name of ur choice, on the url paste the url of the sonarqube, click on server authentication token, select the token we have created and click on apply and save
