#!/bin/bash
#Ce script va créer notre utilisateur qui permettra la copie de notre base de données vers notre serveur esclave
#Ce script fera également la configuration pour la réplication
CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"

export VAULT_TOKEN=$(cat /keys_recup/rootkey.txt | sed -n '1p')

export MYSQL2_USER_SSH=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/MYSQL2_USER_SSH | jq '.data.data.MYSQL2_USER_SSH' | tr -d \")

export MYSQL2_PASSWORD_SSH=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/MYSQL2_PASSWORD_SSH | jq '.data.data.MYSQL2_PASSWORD_SSH' | tr -d \")


adduser $MYSQL2_USER_SSH << _EOF_
$MYSQL2_PASSWORD_SSH
$MYSQL2_PASSWORD_SSH
$MYSQL2_USER_SSH
info
info
info
info
o
_EOF_

adduser $MYSQL2_USER_SSH sudo

mkdir /home/wordpress/conf 

chown -R $MYSQL2_USER_SSH: /home/wordpress/conf

#On ajoute les informations suivantes afin de pouvoir connecter la BDD au cluster pour la réplication 
echo "
[mysqld]
bind-address=0.0.0.0
binlog_format=ROW
innodb_autoinc_lock_mode=2
innodb_flush_log_at_trx_commit=0
wsrep_cluster_name=MariaDBCluster
wsrep_cluster_address="gcomm://172.25.0.2,172.25.0.4,172.25.0.12"
wsrep_node_name=db3
wsrep_node_address="172.25.0.12"
wsrep_on=ON
wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_sst_method=rsync" >> /etc/mysql/my.cnf

#Le container va rejoindre le conteneur et ainsi rejoindre le cluster
mysqld_safe --wsrep_cluster_address="gcomm://172.25.0.2,172.25.0.4,172.25.0.12" \
--wsrep_cluster_name="MariaDBCluster"
else
    echo "-- Not first container startup --"

#A chaque redémarrage du container, le container de BDD se reconnectera au cluster
mysqld_safe --wsrep_cluster_address="gcomm://172.25.0.2,172.25.0.4,172.25.0.12" \
--wsrep_cluster_name="MariaDBCluster"

fi
