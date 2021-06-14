echo "\n\\033[1;33mDémarrage de InfluxDB\\033[0m"
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
