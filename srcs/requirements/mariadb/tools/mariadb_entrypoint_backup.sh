#!/bin/bash

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

sed -i "s/^bind-address/#bind-address/" /etc/mysql/mariadb.conf.d/50-server.cnf
sed -i 's/#port/port/g' /etc/mysql/mariadb.conf.d/50-server.cnf

# WE MUST START "SYSTEMCTL" FOR MARIADB otherwise it is impossible to exec inside
#echo $(/etc/init.d/mysql status)

#echo $(/etc/init.d/mysql start)

# This command wont be necessary as we are already inside the database i guess
# mariadb --user=root -p

# Create new Database for Wordpress if it does not exist yet
if [ ! -d /var/lib/mysql/wordpressDB ]
then
  # We have to start mysql service in order to be albe to connect to it and make changes
  service mysql start;

  mysql -e "CREATE DATABASE wordpressDB;"
  #  delete anonymous user that allows to access database without the password
  #  it is good to have during testing (that means setup) but for production
  #  (that means when we put it to the internet as ready) it should be deleted
  #  for safety.
  mysql -e "DELETE FROM mysql.user WHERE User='';"
  #  removing test database
  mysql -e "DROP DATABASE IF EXISTS test;"
  mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"

  #  % means we can login as root from any IP address
  # "GRANT ALL [PRIVILEGES is optional] ON
  # "WITH GRANT OPTION" - means that this user can grant privileges to other user at the given privilege level
  mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;"

  # Create Regular User (only access to wordpressdb?)
  # IF NOT EXISTS - prevents us to create user if it exists and from errors
  # Currently as if [ ! -d ... ] serves as protector it is not necesary but
  # I am leaving it as in the future I may have better blueprint
  mysql -e "CREATE USER IF NOT EXISTS 'wordpress'@'%' identified by 'wp';"
  mysql -e "GRANT ALL PRIVILEGES ON wordpressDB.* TO 'wordpress'@'%';"
  #lub
  #GRANT ALL ON wordpressDB.* TO 'wordpress'@'localhost' IDENTIFIED BY 'wp' WITH GRANT OPTION;
  mysql -e "FLUSH PRIVILEGES;"

  # We must stop the service because later in Dockerfile there is command "mysqld"
  # that runs mysql in foreground mode
  service mysql stop;
fi

# !!!
# $0 - script itself
# $1 - 1st argument, $2 - 2nd argument (doesnt apply here)
# $@ - refers to all script's arguments aka command line arguments.
# mariadb_entrypoint.sh mysqld_safe - mysqld_safe is an argument to that script
# The way Docker works is that ENTRYPOINT is a script and CMD are arguments to that scritp.
# exec - takes over current process (we frequently use fork with exec inside pogram
#         because exec execute given command and kills itself. In that case it kills
#         forked process so after execution our program may still run) and quits.
#         But in order our contaier to be alive it cant quit, it must stay alive.
#         This is the reason why EVERY DOCKER CONTAINER MUST RUN blocking FOREGROUND cmd.
#         Othewise CMD will be executed (imagine ls -l) and container will exit!!
# Exec $@ says now execute all of the arguments that are present in CMD
exec "$@"
