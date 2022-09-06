#!/bin/bash

sed -ie 's/bind-address/#bind-address/g' /etc/mysql/mariadb.conf.d/50-server.cnf
sed -ie 's/#port/port/g' /etc/mysql/mariadb.conf.d/50-server.cnf

if [ ! -d /var/lib/mysql/wordpressDB ]
then
service mysql start

# https://bertvv.github.io/notes-to-self/2015/11/16/automating-mysql_secure_installation/
mysql --user=root <<pattern_to_end
UPDATE mysql.user SET Password=PASSWORD('buseta') WHERE User='root';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
pattern_to_end

mysql --user=root --password=buseta <<EOF
CREATE DATABASE IF NOT EXISTS wordpressDB;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'buseta';
GRANT ALL PRIVILEGES ON wordpressDB.* TO 'wordpress'@'%' IDENTIFIED BY 'wp' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

service mysql stop
fi

exec "$@"
