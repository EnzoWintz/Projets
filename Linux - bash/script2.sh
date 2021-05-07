#!/bin/bash

#Demande nom utilisateur
read -p "Quel est le nom d'utilisateur que vous voulez rechercher ? :" name_user

#Recherche de l'utilisateur au sein du fichier /etc/passwd
$name_user=`grep -i $name_user /etc/passwd`;

#début de la boucle recherchant les utilisateurs
if [ $name_user=true ];

	then 
		echo "Oui, M/Mme" $name_user "existe"

	else 
		echo "Non, M/Mme" $name_user "n'existe pas"
fi



