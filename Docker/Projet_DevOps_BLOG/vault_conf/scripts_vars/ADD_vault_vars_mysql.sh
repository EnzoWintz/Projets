#!/bin/bash

#Insertion des variables d'environnement pour mysql

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL_ROOT_PASSWORD": "somewordpress" } }' http://172.25.0.10:8200/v1/secret/data/MYSQL_MYSQL_ROOT_PASSWORD

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL_DATABASE": "wordpress" } }' http://172.25.0.10:8200/v1/secret/data/MYSQL_MYSQL_DATABASE

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL_USER": "wordpress" } }' http://172.25.0.10:8200/v1/secret/data/MYSQL_MYSQL_USER

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL_PASSWORD": "wordpress" } }' http://172.25.0.10:8200/v1/secret/data/MYSQL_MYSQL_PASSWORD

#curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "WP_URL": "http://172.25.0.3:8080" } }' http://172.25.0.10:8200/v1/secret/data/MYSQL_WP_URL

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL_SLAVE_IP": "172.25.0.4" } }' http://172.25.0.10:8200/v1/secret/data/MYSQL_MYSQL_SLAVE_IP

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL_SLAVE_USER": "wordpress" } }' http://172.25.0.10:8200/v1/secret/data/MYSQL_MYSQL_SLAVE_USER

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL_SLAVE_PASSWORD": "wordpress" } }' http://172.25.0.10:8200/v1/secret/data/MYSQL_MYSQL_SLAVE_PASSWORD

#curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "WP_URL": "172.25.0.3" } }' http://172.25.0.10:8200/v1/secret/data/MYSQL_WP_URL
