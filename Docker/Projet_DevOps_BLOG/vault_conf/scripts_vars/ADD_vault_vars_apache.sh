#!/bin/bash

#Insertion des variables d'environnement pour apache

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL_ROOT_PASSWORD": "somewordpress" } }' http://172.25.0.10:8200/v1/secret/data/APACHE_MYSQL_ROOT_PASSWORD

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL_DATABASE": "wordpress" } }' http://172.25.0.10:8200/v1/secret/data/APACHE_MYSQL_DATABASE

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL_USER": "wordpress" } }' http://172.25.0.10:8200/v1/secret/data/APACHE_MYSQL_USER

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL_PASSWORD": "wordpress" } }' http://172.25.0.10:8200/v1/secret/data/APACHE_MYSQL_PASSWORD

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "MYSQL_HOST": "172.25.0.2" } }' http://172.25.0.10:8200/v1/secret/data/APACHE_MYSQL_HOST

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "WP_URL": "http://www.wordpressblogavril.org:8080" } }' http://172.25.0.10:8200/v1/secret/data/APACHE_WP_URL

#curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "WP_URL": "http://www.wordpressblogavril.org:8181" } }' http://172.25.0.10:8200/v1/secret/data/APACHE_WP_URL

#curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "WP_URL": "172.25.0.3" } }' http://172.25.0.10:8200/v1/secret/data/APACHE_W>

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "WP_TITLE": "BLOG_AVRIL" } }' http://172.25.0.10:8200/v1/secret/data/APACHE_WP_TITLE

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "WP_ADMIN": "GlobalNet" } }' http://172.25.0.10:8200/v1/secret/data/APACHE_WP_ADMIN

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "WP_MDPADMIN": "wordpress" } }' http://172.25.0.10:8200/v1/secret/data/APACHE_WP_MDPADMIN

curl -H "X-Vault-Token: $VAULT_TOKEN" -H "Content-Type: application/json" -X POST -d '{ "data": { "WP_ADMINMAIL": "globalnet.projet@gmail.com" } }' http://172.25.0.10:8200/v1/secret/data/APACHE_WP_ADMINMAIL
