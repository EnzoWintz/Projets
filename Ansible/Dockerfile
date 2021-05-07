FROM  ubuntu:18.04



RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y net-tools
RUN apt-get install -y ssh



RUN echo 'root:root' |chpasswd



RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN service ssh start
EXPOSE 22
#Ajout du port 80
#EXPOSE 80
EXPOSE 3306

ENTRYPOINT service ssh restart && bash

