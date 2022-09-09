#!/bin/bash

#cant this be inside if?
sed -ie "s/listen = \/run\/php\/php7.3-fpm.sock/listen = $IP:9000/" /etc/php/7.3/fpm/pool.d/www.conf

if [ ! -f "/var/www/html/wp-config.php" ]
then
  # remove wp-config-sample
  rm /wordpress/wp-config-sample.php

  # move all files to volume folder
  mv /wordpress/* /var/www/html/

  #change user:group for every file inside the /html/ to www-data
  #reason: nginx works as www-data
  chown -R www-data:www-data /var/www/html/*

  # remove wordpress folder
  rm -fr /wordpress
fi

exec "$@"

