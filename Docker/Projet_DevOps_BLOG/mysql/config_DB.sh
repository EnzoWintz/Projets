#!/bin/sh

#On démarre mysql avant d'exécuter la commande de configuration
/etc/init.d/mysql start

#On importe les variables depuis le Dockerfile 
export MYSQL_DATABASE
export MYSQL_USER
export MYSQL_PASSWORD
export WP_URL

#Commande qui va créer la base de données et les accrédidation nécessaire pour reçevoir wordpress
mysql -u root -Bse "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;create user $MYSQL_USER@'localhost' IDENTIFIED by '$MYSQL_PASSWORD';GRANT ALL ON *.* TO $MYSQL_USER@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';GRANT ALL ON $MYSQL_DATABASE.* TO $MYSQL_USER@'$WP_URL' IDENTIFIED BY '$MYSQL_PASSWORD';FLUSH PRIVILEGES;"

