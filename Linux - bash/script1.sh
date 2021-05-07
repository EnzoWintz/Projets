#!/bin/bash

#Demande d'utilisateur 
read -p "Donnez un nombre d'utilisateurs :  " nbre_user

#fonction pour faire une addition d'un chiffre
addition () 
{
read -p "Quel est le 1er chiffre à additionner ? :  " addi1
read -p "Quel est le 2ème chiffre à additionner ? :  " addi2
resultat= expr $addi1 + $addi2
echo "Voici le résultat" $resultat "."
}	

#fonction sur les soustraction
soustraction ()
{
read -p "Quel est le 1er chiffre à soustraire ? :  " sous1
read -p "Quel est le 2ème chiffre à soustraire ? :  " sous2
resultat= expr $sous1 - $sous2
echo "Voici le résultat"
}	


#Début menu pour opération
while true
do 
	#affichage des différentes opérations
clear

echo -e "\t CHOIX DES OPERATIONS

\t A + \t   FAIRE UNE ADDITION

\t S - \t   FAIRE UNE SOUSTRACTION

\t Q bye \t QUITTER"

#fin de l'affichage du menu d'option

read answer

#le but est de répéter le menu en fonction du nombre de user entrez au préalable
for i in ( seq $nbre_user ); do

	case "$answer" in

		[Aa]*) addition;;
		[Ss]*) soustraction;;
		[Qq]*) echo "Sortie du programme" ; exit 0
	esac
	read result
	
done
done

