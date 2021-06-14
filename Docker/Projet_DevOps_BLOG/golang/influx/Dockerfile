FROM debian:buster
WORKDIR /opt
EXPOSE 8086

RUN mkdir /data
RUN apt update
RUN apt update --fix-missing
RUN apt full-upgrade -y
RUN apt autoremove -y

RUN apt install -yf \
    wget \
    curl \
    make \
    git

RUN wget https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.6-amd64.deb
RUN dpkg -i influxdb2-2.0.6-amd64.deb

RUN wget https://golang.org/dl/go1.16.4.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.16.4.linux-amd64.tar.gz
RUN rm go1.16.4.linux-amd64.*

RUN touch /data/ipresult.txt
RUN sh -c "echo \"$(ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)\" > /data/ipresult.txt"
RUN echo "\n\033[1;33m--------------------\\033[0m\n\n  Fin ! L'IP de la machine est \\033[1;33m$(cat /data/ipresult.txt)\n\n--------------------\\033[0m\n"

COPY config.sh .
RUN chmod a+x config.sh

ENTRYPOINT [ "influxd" ]