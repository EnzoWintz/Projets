#!/bin/bash
#on se connecte sur notre container vault
#docker-compose exec vault bash

#On créé la clé 
vault operator init > vault/keys_recup/keys.txt

#On créé nos variables basé sur les clé généré précédemment et on les actives dans vault
export UNSEAL3=$(cat vault/keys_recup/keys.txt | sed 's/Unseal Key 3: //g' | sed -n '3p')

vault operator unseal $UNSEAL3

export UNSEAL4=$(cat vault/keys_recup/keys.txt | sed 's/Unseal Key 4: //g' | sed -n '4p')

vault operator unseal $UNSEAL4

export UNSEAL5=$(cat vault/keys_recup/keys.txt | sed 's/Unseal Key 5: //g' | sed -n '5p')

vault operator unseal $UNSEAL5 

#vault operator unseal

#echo -ne '\n'

#$UNSEAL5

export ROOTKEY=$(cat vault/keys_recup/keys.txt | sed 's/Initial Root Token: //g' | sed -n '7p')

echo $ROOTKEY > /vault/keys_recup/rootkey.txt

#On se connecte en tant que root avec la clé root
vault login $(cat vault/keys_recup/keys.txt | sed 's/Initial Root Token: //g' | sed -n '7p')

#On active le fichier de logs
vault audit enable file file_path=/vault/logs/audit.log

#On initialise notre futur repo pour nos variables
vault kv put secret/foo bar=precious

#On active le versionning de notre repo
vault kv enable-versioning secret/

#On quitte notre container
exit
