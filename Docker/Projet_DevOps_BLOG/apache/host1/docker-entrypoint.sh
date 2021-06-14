#!/bin/bash

#Cette boucle fera en sorte que le contenu sera jouer une fois lors du lancement du container et au redémarrage; il passera au lancement d'Apache en mode daemon
CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"

if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"

#Récupération des variables depuis le serveur vault
export VAULT_TOKEN=$(cat /keys_recup/rootkey.txt | sed -n '1p')

export MYSQL_ROOT_PASSWORD=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/APACHE_MYSQL_ROOT_PASSWORD | jq '.data.data.MYSQL_ROOT_PASSWORD' | tr -d \")

export MYSQL_DATABASE=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/APACHE_MYSQL_DATABASE | jq '.data.data.MYSQL_DATABASE' | tr -d \")

export MYSQL_USER=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/APACHE_MYSQL_USER | jq '.data.data.MYSQL_USER' | tr -d \")

export MYSQL_PASSWORD=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/APACHE_MYSQL_PASSWORD | jq '.data.data.MYSQL_PASSWORD' | tr -d \")

export MYSQL_HOST=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/APACHE_MYSQL_HOST | jq '.data.data.MYSQL_HOST' | tr -d \")

export WP_URL=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/APACHE_WP_URL | jq '.data.data.WP_URL' | tr -d \")

export WP_TITLE=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/APACHE_WP_TITLE | jq '.data.data.WP_TITLE' | tr -d \")

export WP_ADMIN=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/APACHE_WP_ADMIN | jq '.data.data.WP_ADMIN' | tr -d \")

export WP_MDPADMIN=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/APACHE_WP_MDPADMIN | jq '.data.data.WP_MDPADMIN' | tr -d \")

export WP_ADMINMAIL=$(curl -H "X-Vault-Token: $VAULT_TOKEN" -X GET http://172.25.0.10:8200/v1/secret/data/APACHE_WP_ADMINMAIL | jq '.data.data.WP_ADMINMAIL' | tr -d \")

#Téléchargement de Wordpress lors du premier démarrage du container
cd /var/www/html/wordpress && \
wp core download --allow-root --locale=fr_FR && \
chown www-data:www-data /var/www/html/wordpress -R && \
chmod -R -wx,u+rwX,g+rX,o+rX /var/www/html/wordpress

#Commandes qui effectueront le paramétrage de wordpress lors de la construction de l'image et une fois celle-ci lancé
wp core config --allow-root --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --dbhost=$MYSQL_HOST --dbprefix=wp --path=/var/www/html/wordpress
wp core install --allow-root --url=$WP_URL --title=$WP_TITLE --admin_user=$WP_ADMIN --admin_password=$WP_MDPADMIN --admin_email=$WP_ADMINMAIL --path=/var/www/html/wordpress

wp term --allow-root create category Docker --description="docker" --path=/var/www/html/wordpress
wp term --allow-root create category Gitlab --description="CI-CD" --path=/var/www/html/wordpress
wp term --allow-root create category Go --description="go" --path=/var/www/html/wordpress
wp term --allow-root create category Infos --description="Informations générales" --path=/var/www/html/wordpress

wp post --allow-root create /scripts-conf/wordpress_conf/docker.txt --post_title='Docker - Mise en place' --post_status=publish --post_category=Docker --post_author=1 --path=/var/www/html/wordpress
wp post --allow-root create /scripts-conf/wordpress_conf/gitlab.txt --post_title='Gitlab - Mise en place' --post_status=publish --post_category=Gitlab --post_author=1 --path=/var/www/html/wordpress
wp post --allow-root create /scripts-conf/wordpress_conf/go.txt --post_title='Go - Mise en place' --post_status=publish --post_category=Go --post_author=1 --path=/var/www/html/wordpress
wp post --allow-root create /scripts-conf/wordpress_conf/info.txt --post_title='Informations Authentification' --post_status=publish --post_category=Infos --post_author=1 --path=/var/www/html/wordpress

else
#Démarrage Apache en mode daemon
apache2ctl -D FOREGROUND

fi
