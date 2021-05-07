FROM centos:latest

RUN yum update \

&& yum upgrade -y \

&& yum install httpd -y

LABEL name_container=enzosuccess

CMD httpd -D FOREGROUND

