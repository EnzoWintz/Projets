#!/bin/bash
#Création du répertoire jenkins
mkdir ~/jenkins

#Installer ensuite docker-compose pour pouvoir utiliser compose dans jenkins
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

#on met les bons droits
chmod +x /usr/local/bin/docker-compose
