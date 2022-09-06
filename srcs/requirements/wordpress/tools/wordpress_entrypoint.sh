#!/bin/bash

#cant this be inside if?
sed -ie "s/listen = \/run\/php\/php7.3-fpm.sock/listen = 0.0.0.0:9000/" /etc/php/7.3/fpm/pool.d/www.conf

ls -l
if [ ! -f "/var/www/html/wp-config.php" ]
then
  # remove wp-config-sample
  rm /wordpress/wp-config-sample.php
  ls -l
  #this is failing because /var/www/html doesnt exist yet (we could mkdir) if we call this from inside
  #dockerfile. Entrypoint script is the first thing called on running container!
  mv /wordpress/* /var/www/html/

  #change user:group for every file inside the /html/ to www-data
  #reason: nginx works as www-data
  chown -R www-data:www-data /var/www/html/*

  rm -fr /wordpress
fi

exec "$@"

