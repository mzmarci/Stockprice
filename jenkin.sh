#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y 
sudo systemctl enable nginx
sudo systemctl start nginx
sudo yum install docker -y
sudo usermod -aG docker ec2-user
sudo service docker start
# Run SonarQube in Docker container
docker run -d --name sonarqube -p 9000:9000 -p 9092:9092 \
                -v sonarqube_data:/opt/sonarqube/data \
                -v sonarqube_extensions:/opt/sonarqube/extensions \
                sonarqube:lts-community
# Verify container is running
docker ps -a | grep sonarqube
 # (Optional) Persist Docker container on reboot
 echo "@reboot root docker start sonarqube" | sudo tee /etc/cron.d/sonarqube_autostart
# Install Java (OpenJDK 17 - Recommended for Jenkins)
sudo yum update -y
sudo yum install -y openjdk-17-jdk
              java -version
# Install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo yum update -y
sudo apt-get install -y jenkins
# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins
 # (Optional) Install useful tools
sudo apt-get install -y 
sudo usermod -aG docker jenkins  # Allow Jenkins to use Docker
# Install prerequisites
sudo yum install -y wget
# Add Trivy repository (RHEL/CentOS/Amazon Linux)
sudo tee /etc/yum.repos.d/trivy.repo
              [trivy]
              name=Trivy repository
              baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/\$releasever/\$basearch/
              gpgcheck=0
              enabled=1
              
# Install Trivy
sudo yum install -y trivy
 # Verify installation
trivy --version
              # (Optional) Alternative installation method using RPM
              # wget https://github.com/aquasecurity/trivy/releases/download/v0.49.1/trivy_0.49.1_Linux-64bit.rpm
              # sudo rpm -ivh trivy_0.49.1_Linux-64bit.rpm