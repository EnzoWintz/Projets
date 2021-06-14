#Déclaration image debian
FROM debian:stable-slim

#Déclaration des arguments
ARG FLAGS="-q -y"
ARG REPOINIT="/"

#mise à jour du container et installation des pkgs nécessaires
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install ${FLAGS} iputils-ping && \
    apt-get install ${FLAGS} curl && \
    apt-get install ${FLAGS} jq && \
    apt-get install ${FLAGS} nano && \
    apt-get install ${FLAGS} openssh-client && \
    apt-get install ${FLAGS} ssh

#Installation MARIADB
RUN apt-get install ${FLAGS} mariadb-server mariadb-client && \
    /etc/init.d/mysql start

#Insertion dossier de la clé root à la racine du container
RUN mkdir /keys_recup
COPY rootkey.txt /keys_recup

#On ajoute le scripts qui s'exécutera dans le container et qui configura la bdd mysql
RUN mkdir /scripts
COPY adduser.sh /scripts
WORKDIR /scripts
RUN chmod +x adduser.sh

#Configuration pour accueillir la connexion de wordpress vers la base mysql
RUN cd /etc/mysql/mariadb.conf.d/ && \
    sed -Ei 's/^(bind-address|log)/#&/' 50-server.cnf && \
    /etc/init.d/mysql restart

#On copie l'adresse IP de chaque hôte de bdd dans le fichier host du container
RUN echo "172.25.0.2  mariadb01" >> /etc/hosts && \
    echo "172.25.0.4  mariadb02" >> /etc/hosts && \
    echo "172.25.0.12 mariadb03" >> /etc/hosts

#Ouverture port BDD
#EXPOSE 3306

#Répertoire par défaut lorsqu'on se connectera sur le container
WORKDIR  ${REPOINIT}

#Script du démarrage du container
CMD ["/bin/sh","-c", "./scripts/adduser.sh"]
