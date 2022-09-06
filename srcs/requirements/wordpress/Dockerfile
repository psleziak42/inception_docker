#here will be needed env variables
#with password database etc

FROM debian:buster

# dependency uptades are done in the image, confiugration in entrypoint
RUN apt update -y
RUN apt upgrade -y
RUN apt -y install wget
RUN wget https://wordpress.org/latest.tar.gz
RUN chmod u+x latest.tar.gz
RUN apt -y install tar -v
RUN tar -xf latest.tar.gz

# i am not sure if it needs to be configured
RUN apt install -y php-fpm
RUN apt install -y php-cli
RUN apt install -y php7.3
RUN apt install -y curl
RUN apt install -y wget
RUN apt install -y php-mysql
RUN apt install -y php-mbstring
RUN apt install -y php-xml
RUN apt install -y sendmail
RUN apt install -y mariadb-client
RUN mkdir /run/php
# apprently necessary to php run correctly
# RUN mkdir -p /var/run/

# trying this to make cmd run with no socker error
RUN /etc/init.d/php7.3-fpm start
RUN /etc/init.d/php7.3-fpm stop

# copy config we want to wordpress
# later all wordpress files are copied to /var/www/html
COPY /conf/wp-config.php /wordpress/wp-config.php
COPY tools/wordpress_entrypoint.sh /usr/bin/

#ENV DB_NAME=wordpress_db
#ENV DB_HOST=127.0.0.1


# we specify entrypoint. This will be run once the container is running, so when compose
# finish execution. It is not running in sequence like regular bash script.
# This means that container is also attached to the volume at this point.
# And we have /var/www/html folder that does not exist before.
# this is the reason why we should do the set up of the container in entrypoint

ENTRYPOINT ["wordpress_entrypoint.sh"]

CMD ["/usr/sbin/php-fpm7.3", "--nodaemonize"]
