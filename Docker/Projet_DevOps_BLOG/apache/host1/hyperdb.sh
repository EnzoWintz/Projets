#!/bin/bash

#On se rend dans le répertoire ou sont les scripts et on télécharge les source de hyperdb
cd /scripts-conf && \
wget https://downloads.wordpress.org/plugin/hyperdb.zip && \
unzip hyperdb.zip 

#On déplace le fichier de configuration dans notre site wordpress
mv /scripts-conf/hyperdb/db-config.php /var/www/html/wordpress/db-config.php && \

#On injecte les données de chaque bdd afin de permettre le failover
echo "
\$wpdb->add_database(array(
        'host'     => '172.25.0.4',     // If port is other than 3306, use host:port.
        'user'     => 'wordpress',
        'password' => 'wordpress',
        'name'     => 'wordpress',
        'write'    => 1,
        'read'     => 1,
        'dataset'  => 'global',
        'timeout'  => 0.2,
));
" >> /var/www/html/wordpress/db-config.php

echo "
\$wpdb->add_database(array(
        'host'     => '172.25.0.12',     // If port is other than 3306, use host:port.
        'user'     => 'wordpress',
        'password' => 'wordpress',
        'name'     => 'wordpress',
        'write'    => 1,
        'read'     => 1,
        'dataset'  => 'global',
        'timeout'  => 0.2,
));
" >> /var/www/html/wordpress/db-config.php

#On déplace le fichier de bdd dans le dossier contenu de wordpress
mv /scripts-conf/hyperdb/db.php /var/www/html/wordpress/wp-content/
