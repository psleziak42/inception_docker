FROM debian:buster

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y mariadb-server

#RUN a command that will comment bind-address in /etc/mysql/mariadb.conf


#RUN sed -i "s/^bind-address/#bind-address/" /etc/mysql/mariadb.conf.d/50-server.cnf
#RUN sed -i 's/#port/port/g' /etc/mysql/mariadb.conf.d/50-server.cnf


#RUN /etc/init.d/mysql start
# this is suppose to create everything needed inside mysql
#COPY /setup.sql /docker-entrypoint-initdb.d/setup.sql

COPY tools/mariadb_entrypoint.sh /usr/local/bin
# - to chyba sprawia ze program nie dziala.
# EXPOSE 3306

# THOSE ARENT NECESSARY! DATABASE CAN BE WITHOUT PASSWORD
#ENV MYSQL_ROOT_PASSWORD=secret
#ENV MYSQL_DATABASE=test_database

ENTRYPOINT ["mariadb_entrypoint.sh"]

CMD ["mysqld_safe"]
