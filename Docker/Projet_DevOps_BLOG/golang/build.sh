#!/bin/bash

# Lancement docker-compose
docker-compose up -d --build

# On pousse la configuration sur le Influx
docker exec influx_service /bin/sh "/opt/config.sh"

sleep 5
docker exec influx_service /usr/bin/telegraf --config /opt/telegraf/globalnet.conf >/dev/null 2>&1 &
