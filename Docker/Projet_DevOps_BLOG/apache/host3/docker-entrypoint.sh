#!/bin/bash

#Cette boucle fera en sorte que le contenu sera jouer une fois lors du lancement du container et au redémarrage; il passera au lancement d'Apache en mode daemon
CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"

if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"

else
#Démarrage Apache en mode daemon
apache2ctl -D FOREGROUND

fi
