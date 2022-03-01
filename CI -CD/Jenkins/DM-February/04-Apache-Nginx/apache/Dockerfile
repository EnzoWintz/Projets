FROM debian:stable-slim

RUN apt-get update -y && \
    apt-get upgrade -y

RUN apt-get install apache2 -y

COPY index.html /var/www/html/

EXPOSE 80

ENTRYPOINT ["apache2ctl", "-D" ,"FOREGROUND"]
