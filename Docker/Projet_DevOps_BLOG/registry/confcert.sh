#!/bin/sh
#générer le certificats automatiquement
#paramètres pour automatiser la création du certificat
COUNTRY=""            
STATE=""            
LOCALITY=""        
ORGNAME="" 
ORGUNIT="" 
EMAIL=""   

#Création du dossier de certificats
mkdir registry/certs

#On génère le certificat
cat <<__EOF__ | openssl req \
    -newkey rsa:4096 -nodes -sha256 -keyout registry/certs/localhost.key \
    -x509 -days 365 -out registry/certs/localhost.crt
$COUNTRY
$STATE
$LOCALITY
$ORGNAME
$ORGUNIT
$site
$EMAIL
__EOF__

#création du second dossier
mkdir registry/auth

#On accorde notre accès à globalnet
docker run --rm \
    --entrypoint htpasswd \
    registry:2.7.0 -Bbn globalnet globalnet > registry/auth/htpasswd

#Création du dossier data qui recevra les images du registry
mkdir registry/data
