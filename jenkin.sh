#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y 
sudo systemctl enable nginx
sudo systemctl start nginx
sudo yum install docker -y
sudo usermod -aG docker ec2-user
sudo service docker start
