#!/bin/bash

#cant this be inside if?
# changing that we will listen on $IP >>any address<< on port 9000
sed -ie "s/listen = \/run\/php\/php7.3-fpm.sock/listen = $IP:9000/" /etc/php/7.3/fpm/pool.d/www.conf
#echo "env[\"MYSQL_DB_NAME\"] = \$MYSQL_DB_NAME" >> /etc/php/7.3/fpm/pool.d/www.conf
if [ ! -f "/var/www/html/wp-config.php" ]
then
  # remove wp-config-sample
  rm /wordpress/wp-config-sample.php

  # move all files to volume folder
  mv /wordpress/* /var/www/html/

  # apparently env variables do not expand automatically in the files because no.
  # it is necessary to substitue them with themselves so it works (i ll add xD here)
  sed -ie s/'$MYSQL_DB_NAME'/$MYSQL_DB_NAME/g /var/www/html/wp-config.php
  sed -ie s/'$MYSQL_DB_USER'/$MYSQL_DB_USER/g /var/www/html/wp-config.php
  sed -ie s/'$MYSQL_DB_PASS'/$MYSQL_DB_PASS/g /var/www/html/wp-config.php
  sed -ie s/'$DB_HOSTNAME'/$DB_HOSTNAME/g /var/www/html/wp-config.php

  #change user:group for every file inside the /html/ to www-data
  #reason: nginx works as www-data
  chown -R www-data:www-data /var/www/html/*

  # remove wordpress folder
  rm -fr /wordpress
fi

exec "$@"

