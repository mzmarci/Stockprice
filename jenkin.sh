#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y 
sudo systemctl enable nginx
sudo systemctl start nginx

# Copy frontend files
mkdir -p /usr/share/nginx/html
cp /home/ec2-user/Stockprice/frontend/index.html /usr/share/nginx/html/
cp /home/ec2-user/Stockprice/frontend/header.png /usr/share/nginx/html/
chmod -R 755 /usr/share/nginx/html

# Restart nginx to reflect changes
sudo systemctl restart nginx

# Update and install prerequisites
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo yum install -y  awscli
# Start and enable Docker
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl restart docker  # Optional extra safety
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins  # Allow Jenkins to use Docker

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
# Run Jenkins container
docker run -d \
  --name jenkins \
  --restart unless-stopped \
  -u root \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/jenkins_home:/var/jenkins_home \
  -v $(which docker):/usr/bin/docker \
  -v $(which aws):/usr/bin/aws \
  -v /home/ec2-user/.aws:/var/jenkins_home/.aws \
  jenkins/jenkins:lts

# Verify container
docker ps | grep jenkins


echo ":hammer_and_wrench: Installing AWS CLI and Docker CLI inside Jenkins container..."
docker exec -u root jenkins bash -c "
  curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip' && \
  apt-get update && apt-get install -y unzip && \
  unzip awscliv2.zip && ./aws/install
"



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
