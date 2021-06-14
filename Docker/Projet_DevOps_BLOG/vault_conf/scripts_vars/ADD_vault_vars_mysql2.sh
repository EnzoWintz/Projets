#!/bin/bash

#Insertion des variables d'environnement pour mysql

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL2_USER_SSH": "wordpress" } }' http://172.25.0.10:8200/v1/secret/data/MYSQL2_USER_SSH

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL2_PASSWORD_SSH": "wordpress" } }' http://172.25.0.10:8200/v1/secret/data/MYSQL2_PASSWORD_SSH

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL2_HOME_BASE_SSH": "/home/" } }' http://172.25.0.10:8200/v1/secret/data/MYSQL2_HOME_BASE_SSH

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL_MASTER_HOST": "172.25.0.2" } }' http://172.25.0.10:8200/v1/secret/data/MYSQL_MASTER_MYSQL_HOST
