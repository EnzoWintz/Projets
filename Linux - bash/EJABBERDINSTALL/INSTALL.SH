#!/bin/bash


#fontions

#Installation de ejabberd et verification de l'installation 

install1 ()
{ clear
  ./EJABBERDINSTALL/STYLES/INSTALL.sh                                 
  sleep 2
  apt-get install ejabberd                                                 
  	
  clear

  if [ -d "/usr/lib/erlang" ]; then                                             
	echo "ERL EST INSTALLE"
  else
	echo "ERL N'EST PAS INSTALLE"
  fi

  if [ -d "/etc/ejabberd" ]; then
  	echo "EJABBERD EST INSTALLE"
 	cp /EJABBERDINSTALL/ejabberd.yml.orig /etc/ejabberd/ejabberd.yml
  	verif=`grep "###NEWUSER" /etc/ejabberd/ejabberd.yml | wc -l`

  	if [ $verif = 1 ]; then
 		echo "LE FICHIER EST BIEN COPIE"
  	else
		echo "LE FICHIER CONF N'EST PAS COPIE" 
  	fi
  else
	echo "EJABBERD N'EST PAS INSTALLE"
  fi
  sleep 1
  echo "APPUYER SUR ENTER"
}

#Desinstallation de erlang et ejabberd

desinstall ()
{ clear
  ./EJABBERDINSTALL/STYLES/UNINSTALL.sh
  sleep 2
  apt-get remove --purge ejabberd*
  apt-get remove --purge erlang*
  find /etc/ejabberd -delete
  clear
  
  if [ -d "/usr/lib/erlang" ]; then
	echo "ERL N'A PAS ETE DESINSTALLER"
  else
	echo "ERL A ETE DESINSTALLER"
  fi

  if [ -d "/etc/ejabberd" ]; then
  	echo "EJABBERD N'A PAS ETE DESINSTALLER"
  else
	echo "EJABBERD A ETE DESINSTALLER"
  fi
  sleep 1
  echo "DESINSTALATION TERMINE"
  sleep 1
  echo "APPUYER SUR ENTER"
}




#Configuration de ejabberd et creation du certificat

configuration ()
{ clear
  ./EJABBERDINSTALL/STYLES/CONF.sh
  sleep 2
  mv /etc/ejabberd/ejabberd.pem /etc/ejabberd/ejabberd.pem.orig
  openssl req -new -x509 -newkey rsa:1024 -days 3650 -keyout privkey.pem -out server.pem
  openssl rsa -in privkey.pem -out privkey.pem
  cat privkey.pem >> server.pem
  rm privkey.pem
  mv server.pem /etc/ejabberd/ejabberd.pem
  chown root:ejabberd /etc/ejabberd/ejabberd.pem
  chmod 640 /etc/ejabberd/ejabberd.pem

  if [ -d "/run/ejabberd" ]; then
  	chmod 777 /run/ejabberd
  else
  	mkdir /run/ejabberd
  	chmod 777 /run/ejabberd
  fi
  sleep 4
  ejabberdctl start
  clear
  echo "EJABBERD DEMARER"
  if [ -f /etc/ejabberd/ejabberd.pem ]; then
  	echo "LE CERTIFICAT EST INSTALLE"
  else
	echo "LE CERTIFICAT N'EST PAS INSTALLE"
  fi
 
  sleep 1
  echo "APPUYER SUR ENTER"
}

#Ajouts des utilisateurs

adduser ()
{ clear
  ./EJABBERDINSTALL/STYLES/ADDUSER.sh
  read -p "QUELLE EST LE NOM DU NOUVELLE UTILISATEUR ? " user
  read -p "MOT DE PASSE POUR L'UTILISATEUR $user : " mdp
  verif=`grep "$user@localhost" /etc/ejabberd/ejabberd.yml | wc -l`
  if [ $verif = 1 ]; then
  	echo "L'UTILISATEUR $user EXISTE DEJA"
  else 
	sed -i "s/###NEWUSER/- "$user"@localhost\n      ###NEWUSER/g" /etc/ejabberd/ejabberd.yml
  	ejabberdctl register $user localhost $mdp
  	echo "L'UTILISATEUR $user A ETE AJOUTE"
  fi
  sleep 1
  echo "APUYER SUR ENTER"
}

#Suppresion des utilisateurs 

deleteuser ()
{ ./EJABBERDINSTALL/STYLES/DELETUSER.sh
  read -p "QUELLE EST LE NOM DE L'UTILISATEUR A SUPPRIME ? " duser
  verif=`grep "$duser@localhost" /etc/ejabberd/ejabberd.yml | wc -l`
  if [ $verif = 0 ]; then
	echo "L'UTILISATEUR $duser N'EXISTE PAS"
  else
  	sed -i /$duser"@localhost"/d /etc/ejabberd/ejabberd.yml
  	ejabberdctl unregister $duser localhost
  	sleep 1
  	echo "L'UTILISATEUR $duser A BIEN ETE SUPPRIME"
  fi
  sleep 1 
  echo "APUYER SUR ENTER"
}

#Reset du fichier de configuration 

reset1 ()
{ clear
  ./EJABBERDINSTALL/STYLES/RESTO.sh
  echo "RESET DE LA CONFIGURATION EJABBERD"
  sleep 2
  cp /EJABBERDINSTALL/ejabberd.yml.orig /etc/ejabberd/ejabberd.yml
  echo "LA CONFIGURATION A ETE RESET"
  sleep 1
  echo "APPUYER SUR ENTER"
}


while true

do

#affichage du menu
	clear
	./EJABBERDINSTALL/STYLES/TITLE.sh
	echo -e "
\t I -- \t INSTALLATION EJABBERD
\t D -- \t DESSINSTALATION EJABBERD

\t C -- \t CONFIGURATION 

\t U -- \t AJOUT UTILISATEUR
\t S -- \t SUPPRESION UTILISATEUR

\t R -- \t RESET CONF EJABBERD

\t Q -- \t QUITTER LINSTALATION

\t Entrez une lettre pour choisir l'action
\t Appuyer sur ENTER"

read reponse
clear

#selection du menu
case "$reponse" in
	[Ii])install1;;

	[Dd])desinstall;;
	
	[Cc])configuration;;

	[Uu])adduser;;

	[Ss])deleteuser;;

	[Rr])reset1;;

	[Qq]) exit 0;;	
esac

read result

done



