#Déclaration image debian
FROM debian:stable-slim

#Inclusion des métadonnées de l'image
LABEL version="1.0" maintainer="WINTZ ENZO <enzo.wintz1@outlook.fr>"

#Déclaration des arguments
ARG FLAGS="-q -y"
ARG REPOINIT="/"

#Variables d'envirronnements
ENV MYSQL_ROOT_PASSWORD=somewordpress
ENV MYSQL_DATABASE=wordpress
ENV MYSQL_USER=wordpress
ENV MYSQL_PASSWORD=wordpress
ENV WP_URL=172.25.0.3

#mise à jour du container
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install ${FLAGS} iputils-ping

#Installation MARIADB
RUN apt-get install ${FLAGS} mariadb-server mariadb-client && \
    /etc/init.d/mysql start

#On ajoute le scripts qui s'exécutera dans le container et qui configura la bdd mysql
RUN mkdir /scripts
COPY config_DB.sh /scripts
WORKDIR /scripts
RUN chmod +x config_DB.sh && \
    /etc/init.d/mysql start && \
    ./config_DB.sh

#Configuration pour accueillir la connexion de wordpress vers la base mysql
RUN cd /etc/mysql/mariadb.conf.d/ && \
    sed -Ei 's/^(bind-address|log)/#&/' 50-server.cnf && \
    /etc/init.d/mysql restart

#Ouverture port BDD
EXPOSE 3306

#Répertoire par défaut lorsqu'on se connectera sur le container
WORKDIR  ${REPOINIT}

#On démarre mysql lors du démarrage du container
CMD ["mysqld_safe"]
