#!/bin/bash
#Création du répertoire avec up du contener portainer
mkdir -p docker/portainer
cd docker/portainer && docker-compose up -d

