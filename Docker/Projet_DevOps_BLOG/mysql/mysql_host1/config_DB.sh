#!/bin/sh

CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"
CONTAINER_SECOND_START="CONTAINER_ALREADY_STARTED_TWICE"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"
#On importe les variables depuis vault en utilisant le jeton token

export VAULT_TOKEN=$(cat /keys_recup/rootkey.txt | sed -n '1p')

export MYSQL_ROOT_PASSWORD=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/MYSQL_MYSQL_ROOT_PASSWORD | jq '.data.data.MYSQL_ROOT_PASSWORD' | tr -d \")

export MYSQL_DATABASE=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/MYSQL_MYSQL_DATABASE | jq '.data.data.MYSQL_DATABASE' | tr -d \")

export MYSQL_USER=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/MYSQL_MYSQL_USER | jq '.data.data.MYSQL_USER' | tr -d \")

export MYSQL_PASSWORD=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/MYSQL_MYSQL_PASSWORD | jq '.data.data.MYSQL_PASSWORD' | tr -d \")

#export WP_URL=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/MYSQL_WP_URL | jq '.data.data.WP_URL' | tr -d \")

export MYSQL_SLAVE_IP=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/MYSQL_MYSQL_SLAVE_IP | jq '.data.data.MYSQL_SLAVE_IP' | tr -d \")

export MYSQL_SLAVE_USER=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/MYSQL_MYSQL_SLAVE_USER | jq '.data.data.MYSQL_SLAVE_USER' | tr -d \")

export MYSQL_SLAVE_PASSWORD=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/MYSQL_MYSQL_SLAVE_PASSWORD | jq '.data.data.MYSQL_SLAVE_PASSWORD' | tr -d \")


#Configuration de la base de données
service mysql start && \
mysql -u root -Bse "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;create user $MYSQL_USER@'localhost' IDENTIFIED by '$MYSQL_PASSWORD';GRANT ALL ON *.* TO $MYSQL_USER@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';GRANT ALL ON $MYSQL_DATABASE.* TO $MYSQL_USER@'%' IDENTIFIED BY '$MYSQL_PASSWORD';FLUSH PRIVILEGES;"

#Configuration du container afin de permettre la création du cluster de réplication
echo "
[mysqld]
bind-address=0.0.0.0
binlog_format=ROW
innodb_autoinc_lock_mode=2
innodb_flush_log_at_trx_commit=0
wsrep_cluster_name=MariaDBCluster
wsrep_cluster_address="gcomm://172.25.0.2,172.25.0.4,172.25.0.12"
wsrep_node_name=db1
wsrep_node_address="172.25.0.2"
wsrep_on=ON
wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_sst_method=rsync" >> /etc/mysql/my.cnf

elif [ ! -e $CONTAINER_SECOND_START ]; then
    touch $CONTAINER_SECOND_START
    echo "DATABSE SERVER SECOND START"

#On va configurer la création de notre cluster afin d'acceuillir la réplication
mysqld_safe --wsrep-new-cluster

else
    echo "-- More than two restart --"
#On démarrare ces service lors du redémarrage du container
    service ssh start && \
    mysqld_safe
fi


