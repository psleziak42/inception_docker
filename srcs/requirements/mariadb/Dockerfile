#should we add version here?
FROM debian:buster

RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get install -y vim
RUN apt-get install -y mariadb-server

COPY tools/mariadb_entrypoint_backup.sh /usr/local/bin

ENTRYPOINT ["mariadb_entrypoint_backup.sh"]

CMD ["mysqld_safe"]
