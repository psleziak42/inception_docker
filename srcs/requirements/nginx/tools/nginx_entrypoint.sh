#!/bin/bash

# Exits script if one of the commands fail
set -e

if [ ! -f "/etc/nginx/sites-enabled/configuration.conf" ]
then
  # Delete default configuration
  rm -f /etc/nginx/sites-avaliable/default /etc/nginx/sites-enabled/default

  # Must link config.conf to sites-avaliable on nginx container. It could be also copied.
  # But linking has that advantage than it is only necessary to change one file and link
  # is automatically the same.
  ln -s /etc/nginx/sites-avaliable/configuration.conf /etc/nginx/sites-enabled/configuration.conf

  # Create self signed key and certificate
  openssl req -x509 -nodes -days 365 -subj "/C=PT/ST=L/O=42/OU=student/CN=psleziak.42.fr/emailAddress=." -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt

  # This can substitue -g flag in CMD dockerfile. nginx \-g\ - goest to the file and substitue \daemon off'\
  sed -ie 's/gzip on;/gzip off;/g' /etc/nginx/nginx.conf
  # Command check if configuration file is ok.
  nginx -t
fi

exec "$@"
