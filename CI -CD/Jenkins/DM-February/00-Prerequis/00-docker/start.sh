#!/bin/bash
#Installation de docker
sudo apt update -y
sudo apt upgrade -y
sudo apt install ca-certificates -y && sudo apt install curl -y && sudo apt install gnupg -y && sudo apt install lsb-release -y
sudo curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
sudo echo deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian buster stable | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt install docker-ce docker-ce-cli containerd.io -y
docker -v

#Installation de docker-compose
sudo curl -L https://github.com/docker/compose/releases/download/1.25.3/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
