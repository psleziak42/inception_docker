FROM debian:buster

# dependency uptades are done in the image, confiugration in entrypoint
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y vim
RUN apt-get install wget -y
RUN wget https://wordpress.org/latest.tar.gz
RUN chmod u+x latest.tar.gz
RUN apt-get -y install tar -v
RUN tar -xf latest.tar.gz

RUN apt-get install -y php-fpm
RUN apt-get install -y php-cli
RUN apt-get install -y php7.3
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y php-mysql
RUN apt-get install -y php-mbstring
RUN apt-get install -y php-xml
RUN apt-get install -y sendmail
RUN apt-get install -y mariadb-client
# apprently necessary to php run correctly
RUN mkdir -p /run/php

# trying this to make cmd run with no socket error
RUN /etc/init.d/php7.3-fpm start
RUN /etc/init.d/php7.3-fpm stop

# copy config we want to wordpress
# later all wordpress files are copied to /var/www/html
COPY /conf/wp-config.php /wordpress/wp-config.php
COPY tools/wordpress_entrypoint.sh /usr/bin/

#ENV DB_NAME=wordpress_db
#ENV DB_HOST=127.0.0.1

# LESSON no. 2 about ENTRYPOINT
#
# DOCKERFILE is not regular bash script. It is not running in sequence. I mean it is
# and it is not. ENTRYPOINT is the FIRST INSTRUCTION TO BE EXECUTED ON RUNNING
# CONTAINER (if we use compose, it is after compose is done).
# What it means? Well first container must be created, connected to volume and network
# if they are specified. Once it fully exists we run entrypoint.sh.
# Why this info is so important? Some instructions may fail if we put them too early.
# I encountered problem with this: "mv /wordpress/* /var/www/html/" that i was running
# right after i unzipped downloaded wordpress. /var/www/html is a volume storage that
# at that point was not attached yet to the container.
#
# How to think about ENTRYPOINT?
#
# Think about it as a place where we put instructions that are suppose to
# configure the environment inside container eg. move files, change script
# permissions, owners, set up installed database etc.
#
# How to thing about DOCKERFILE?
#
# Think about it as a place where we create the environment.
# This means installing dependencies (OS, all necessary applications - php, vim etc)
# Here we COPY files from our host (my Ubuntu) to container, we also pass ENVIRONEMNTAL
# variables. Have in mind that we MUST first COPY ENTRYPOINT.SH to the container to be able
# to run it. We should specify FULL path to the script, UNLESS we put it inside /usr/bin or
# any other path that is part of PATH variable. In my case i do this so I only run
# ["wordpress_entrypoint.sh"], otherwise it would have to be eg ["/extras/wp_entry.sh"]

ENTRYPOINT ["wordpress_entrypoint.sh"]

# CMD - command - are Command Line Arguments for ENTRYPOINT. So it all looks as we would
# execute: wordpress_entrypoint.sh /usr/sbin/php-fpn7.3 --nodaemonize in bash
#
# The proper way to deal with containers is to have ONE PROCESS PER CONTAINER. This way
# it is pretty easy to controll, as it is straight away visible which container does what
# and if we turn off eg. wordpress_ we know that mariadb is still running.
#
# WHAT IS PROCESS? - in my understandement process is running program. As long as process
# runs - program runs. If we put infinite loop inside program its gonna run forever. This
# is how computer-games are build, but also shell we use. If you type "bash" on your cli
# and follow it with ps you gonna see you have 2 processes. That bash works kinda on top
# of shell from which the command was executed.
#
# HOW SHELL WORKS?
# From project "Minishell" I may say it is an infinite loop that waits for a "line".
# Once it is passed to the program parser reads it and execute commands accordingly.
# Elements are separated by space(s) and usually 1st thing is a command (eg ls) and
# after that is known as an option (eg -l). To execute ls -l or any other we use
# function exec combind with fork, as exec execute and terminates the process.
#
# Coming back to the container, ls -l is NON BLOCKING command. It will show us a
# list of directories inside container and process will end, container will die.
# But if we use BLOCKING command like cat/grep/tail -f (that were prohibided in
# this project) they will wait for an input and as long as input wont be provided
# container will stay alive.
#
# Combining it all: ONE CONTAINER = ONE PROCESS. Process then cant run as daemon
# (this means in the background) but must be explicitly specified to work on
# foreground. Hence here I use "--nodaemonize" flag, that is equivalent to "-F".
# (in ngnix you may see "-g" - that stays for "go to options and turn "nodeamopize=off")
CMD ["/usr/sbin/php-fpm7.3", "--nodaemonize"]
