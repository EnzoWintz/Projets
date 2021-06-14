#Déclaration image debian
FROM debian:stable-slim

#Déclaration des arguments
ARG FLAGS="-q -y"
ARG REPOINIT="/var/www/html"

#Installation Apache et autres packages
RUN apt-get update -y && \
    apt-get install ${FLAGS} apache2 && \
    apt-get install ${FLAGS} php libapache2-mod-php php-mysqli && \
    apt-get install ${FLAGS} wget && \
    apt-get install ${FLAGS} unzip && \
    apt-get install ${FLAGS} iputils-ping && \
    apt-get install ${FLAGS} nano && \
    apt-get install ${FLAGS} curl && \
    apt-get install ${FLAGS} mariadb-client && \
    apt-get install ${FLAGS} jq

#Insertion dossier de la clé root
RUN mkdir /keys_recup
COPY rootkey.txt /keys_recup

#OUVERTURE DU PORT TCP 8080
#EXPOSE 8181
EXPOSE 8080

#RÉPERTOIRE DE TRAVAIL une fois qu'on se connectera au conteneur
WORKDIR  ${REPOINIT}

#Installation de WP-CLI qui permettra d'administrer Wordpress
RUN cd /opt && \
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

#Installation Wordpress en français
#RUN mkdir ${REPOINIT}/wordpress && \
#    cd ${REPOINIT}/wordpress && \
#    wp core download --allow-root --locale=fr_FR && \
#    chown www-data:www-data /var/www/html/wordpress -R && \
#    chmod -R -wx,u+rwX,g+rX,o+rX /var/www/html/wordpress 

#Redirection wordpress lorsque IP du container est saisie dans le navigateur
RUN cd /etc/apache2/ && \
    sed -i 's/Listen 80$/Listen 0.0.0.0:8080/' ports.conf && \
    service apache2 restart

#Copie des scripts qui s'exécuteront sur le container une fois lancé
RUN mkdir /scripts-conf

COPY docker-entrypoint.sh /scripts-conf
RUN cd /scripts-conf && \
    chmod +x docker-entrypoint.sh

#On copie le contenu de nos pages qui peupleront notre blog
#COPY wordpress_conf/docker.txt /scripts-conf
#COPY wordpress_conf/swarm.txt /scripts-conf
#COPY wordpress_conf/gitlab.txt /scripts-conf
#COPY wordpress_conf/go.txt /scripts-conf

COPY wordpress.conf /scripts-conf
RUN service apache2 start && \
    cd /scripts-conf && \
    chmod 744 wordpress.conf && \
    a2enmod rewrite && \
    rm /etc/apache2/sites-available/000-default.conf && \
    rm /etc/apache2/sites-enabled/000-default.conf && \
    cp wordpress.conf /etc/apache2/sites-available/wordpress.conf && \
    a2ensite wordpress.conf && \
    service apache2 reload
    

#On démarre notre commande puis le serveur apache
#ENTRYPOINT ["/bin/sh","-c","/scripts-conf/docker-entrypoint.sh && /scripts-conf/apache-entrypoint.sh"]
ENTRYPOINT ["/bin/sh","-c","/scripts-conf/docker-entrypoint.sh"]

