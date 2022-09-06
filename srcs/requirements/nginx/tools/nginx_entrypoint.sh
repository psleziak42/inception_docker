#!/bin/bash
#WORKING

# Exits script if one of the commands fail
set -e
# Delete default configuration
rm -f /etc/nginx/sites-avaliable/default /etc/nginx/sites-enabled/default

if [ ! -f "/etc/nginx/sites-enabled/configuration.conf" ]
then
  # Must link config.conf to sites-avaliable on nginx container
  ln -s /etc/nginx/sites-avaliable/configuration.conf /etc/nginx/sites-enabled/configuration.conf
fi

#PUT IT INSIDE IF SO ITS NOT CLALED EVERYTIME
#create self signed key and certificate
openssl req -x509 -nodes -days 365 -subj "/C=PT/ST=L/O=42/OU=student/CN=psleziak.42.fr/emailAddress=." -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt

#create strong Diffie-Hellman group, which is used in negotiating Perfect Forward Secrecy with clients
#openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# Must start php-fpm service - php moved to wordpress container
#/etc/init.d/php7.3-fpm start

# this can substitue -g flag in CMD dockerfile. nginx \-g\ - goest to the file and substitue \daemon off'\
sed -ie 's/gzip on;/gzip off;/g' /etc/nginx/nginx.conf
# Check if config file is ok
nginx -t

# TEST FOLDER
#touch buseta.c

exec "$@"
