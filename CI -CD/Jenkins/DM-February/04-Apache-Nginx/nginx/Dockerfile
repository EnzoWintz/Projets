FROM ubuntu
RUN apt-get update -y && \
    apt-get upgrade -y

RUN apt-get install nginx -y

COPY index.html /var/www/html/

EXPOSE 80

CMD ["nginx","-g","daemon off;"]
