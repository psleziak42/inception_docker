#should we add version here?
FROM debian:buster

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y mariadb-server

COPY tools/mariadb_entrypoint_backup.sh /usr/local/bin
COPY conf/wordpressDB.sql /tmp/
ENTRYPOINT ["mariadb_entrypoint_backup.sh"]

CMD ["mysqld_safe"]
