#!/bin/bash

echo -e "\n\\033[1;33mDémarrage de InfluxDB\\033[0m"
until $(curl --output /dev/null --silent --head --fail http://localhost:8086); do # Tant que Influx ne répond pas,
    printf '.'                                                                    # On imprime un point,
    sleep 1                                                                       # Toutes les secondes
done

# Application de la config
influx setup -b globalnet -f --json -n globalnet -o globalnet -p globalnet -u globalnet
# Nom du bucket : globalnet
# Nom de la config : globalnet
# Organisation : globalnet
# Mot de passe : globalnet
# Nom d'utilisateur : globalnet

# Récupération du token
grep token /root/.influxdbv2/configs | head -n1 | sed 's/"//g' | cut -d " " -f 5 >/data/token.txt

################# PARTIE TELEGRAF ######################

export IPRESULT="http://localhost:8086"
export TOKENRESULT="$(cat /data/token.txt)"

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$(go env GOPATH)/bin
export GOPATH=$(go env GOPATH)

git clone https://github.com/influxdata/telegraf.git
cd "telegraf/"
git checkout -b powertop

cat <<EOF >globalnet.conf
[agent]
    interval = "10s"
    round_interval = true
    metric_batch_size = 1000
    metric_buffer_limit = 10000
    collection_jitter = "0s"
    flush_interval = "10s"
    flush_jitter = "0s"
    precision = ""
    debug = true
    quiet = false
    logfile = ""
    hostname = ""
    omit_hostname = false
[[outputs.influxdb_v2]]
    urls = [ "$IPRESULT" ]
    token = "$TOKENRESULT"
    organization = "globalnet"
    bucket = "globalnet"
[[inputs.powertop]]
EOF

sed -i '$d' plugins/inputs/all/all.go
echo -e "        _ \"github.com/influxdata/telegraf/plugins/inputs/powertop\"\n)" >>plugins/inputs/all/all.go

mkdir plugins/inputs/powertop
wget https://framagit.org/math3r0se/powertop/-/raw/main/powertop.csv -O plugins/inputs/powertop/powertop.csv
wget https://framagit.org/math3r0se/powertop/-/raw/main/powertop.go -O plugins/inputs/powertop/powertop.go

make telegraf

ln -s /opt/telegraf/telegraf /usr/bin/telegraf

echo -e "\033[1;33m########## FIN ##########\033[0m"
