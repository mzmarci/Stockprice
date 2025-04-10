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
# Run Jenkins in Docker
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts
 # (Optional) Install useful tools
sudo apt-get install -y 
sudo usermod -aG docker jenkins  # Allow Jenkins to use Docker

# Install dependencies
sudo yum update -y
sudo yum install -y wget tar

# Download and install latest Trivy release
TRIVY_VERSION=$(curl -s https://api.github.com/repos/aquasecurity/trivy/releases/latest | grep tag_name | cut -d '"' -f 4)
wget https://github.com/aquasecurity/trivy/releases/download/${TRIVY_VERSION}/trivy_${TRIVY_VERSION:1}_Linux-64bit.tar.gz

# Extract and move to /usr/local/bin
tar zxvf trivy_${TRIVY_VERSION:1}_Linux-64bit.tar.gz
sudo mv trivy /usr/local/bin/

# Verify installation
trivy --version
