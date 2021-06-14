#!/bin/bash

#On créé le fichier .json pour permettre la configuration du load balancing de traffik des nos apaches
touch traefik/conf/acme.json

#On attribue les droits nécessaire au fichier .json de configuration
chmod 600 traefik/conf/acme.json

#Commande qui va créer le vault qui stockera les variables
docker-compose -f vault_conf/vault-compose.yml up -d --build 

#On exécute le script de configuration de Vault en se connectant sur le container
docker exec vault_SDV ./vault/config/VAULT_conf.sh bash

#On export le jeton root de Vault qui servira à la connexion sur Vault
export VAULT_TOKEN=$(cat vault_conf/vault/keys_recup/rootkey.txt | sed -n '1p')

#On injecte les variable pour apache sur Vault
./vault_conf/scripts_vars/ADD_vault_vars_apache.sh

#On injecte les variables pour le master mysql sur Vault
./vault_conf/scripts_vars/ADD_vault_vars_mysql.sh

#On injecte les variables pour le slave mysql2 sur Vault
./vault_conf/scripts_vars/ADD_vault_vars_mysql2.sh

docker-compose -f traefik/traefik.yml up -d

#On copie le jeton root dans les dossiers apache, mysql et mysql2
./copy_rootkey.sh

#On configure le certificat SSL de notre registrie
./registry/confcert.sh

#On démarre notre registry
docker-compose -f repo.yml up -d

#On build nos images apache, mysql et mysql2 sans les démarrer
docker-compose -f build_repo/build_before_push.yml up --no-start

#On purge nos containers qui ne sont pas démarrés car ils seront push sur notre registrie
./build_repo/purge_tmp_container.sh

#On push nos images local sur le registrie et on les supprime en local pour les pull depuis le registrie
./registry/config_repo.sh

#On démarre InfluxDB
docker-compose -f golang/influx.yml up -d

#On exectute le script qui va configurer InfluxDB et télécharger téléraf
docker exec influxDB_SDV /bin/bash "/opt/config.sh"

#On ajoute un temps d'attente de secondes afin de limiter les erreurs potentielles
sleep 5

#On donne la configuration à influxdb en utilisant le binaire généré par télégraphe
docker exec influxDB_SDV /usr/bin/telegraf --config /opt/telegraf/globalnet.conf >/dev/null 2>&1 &

#On démarre le container de base de données primaire
docker-compose up -d db

sleep 8

#On démarre le serveur apache qui permettra de configurer wordpress
docker-compose up apache-php_host1

#On démarre le second apache
docker-compose up -d apache-php_host2

#On démarre le troisième apache
docker-compose up -d apache-php_host3

#On démarre notre seconde base de données 
docker-compose up -d db2

#On démarre notre troisième base de données
docker-compose up -d db3

#On joue le script de configuration du failover
docker exec apache-php_load1_SDV bash -c "cd /scripts-conf/ ; ./hyperdb.sh"
