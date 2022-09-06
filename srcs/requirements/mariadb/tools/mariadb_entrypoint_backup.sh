#!/bin/bash

# Why we create "admin" user?
# Root user is sort of admin, but it is not password but socket identified.
# Dunno what it exactly means but having admin with password provides easier
# access to the DB

#to bylo w moim wordpress_entrypoint
#/etc/mysql/mariadb.conf.d/50-server.cnf

# SOME COMMANDS:
# - SELECT USER()/CURRENT_USER(); - whoami
# - SELECT User FROM mysql.user; - shows all users
# - SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'username') - find if user already exists
# - SHOW DATABASES; - shows databases
# - SHOW GRANTS FOR 'username'@'localhost'; - shows
# - REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'username'@'localhost' - revoke all grants from a user
# - DROP USER IF EXISTS 'username'@'localhost'; - deletes user if the user exists
    # many users: 'username'@'localhost', 'username2'@'localhost', 'username3' if it was created without @localhost
# - DROP DATABASE [database_name] - database name

# Exits script if one of the commands fail
set -e
service mysql start;

sed -i "s/^bind-address/#bind-address/" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i 's/#port/port/g' /etc/mysql/mariadb.conf.d/50-server.cnf

# WE MUST START "SYSTEMCTL" FOR MARIADB otherwise it is impossible to exec inside
#echo $(/etc/init.d/mysql status)

#echo $(/etc/init.d/mysql start)

# This command wont be necessary as we are already inside the database i guess
# mariadb --user=root -p

#loggin in to database


# Create new Database for Wordpress if it does not exist yet
if [ ! -d /var/lib/mysql/wordpressDB ]
then
	mysql -e "CREATE DATABASE wordpressDB;"

# NOT SURE IF NECESSARY:
# USE [database name]; - to make database active

#mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '' WITH GRANT OPTION;"

# Create Admin User
# CREATE USER 'superuser'@localhost identified by 'tightconnector'
# GRANT ALL PRIVILEGES ON *.* TO 'superuser'@localhost
#lub
# that part '172.18.0.2/16' works with % but i try to see if other options work also (or change % or try nginx_)
mysql -e "GRANT ALL ON *.* TO 'superuser'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;"
mysql -e "FLUSH PRIVILEGES;"
# "GRANT ALL [PRIVILEGES is optional] ON - word privileges is optional
# "WITH GRANT OPTION" - means that this user can grant privileges to other user at the given privilege level

# Create Regular User (only access to wordpressdb?)
mysql -e "CREATE USER IF NOT EXISTS 'wordpress'@'%' identified by 'wp';"
mysql -e "GRANT ALL PRIVILEGES ON wordpressDB.* TO 'wordpress'@'%';"
#lub
#GRANT ALL ON wordpressDB.* TO 'wordpress'@'localhost' IDENTIFIED BY 'wp' WITH GRANT OPTION;
mysql -e "FLUSH PRIVILEGES;"

#mysql -u superuser -ppassword -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'buseta';"

#mysqladmin -u root -pbuseta shutdown;
service mysql stop;
fi

exec "$@"
