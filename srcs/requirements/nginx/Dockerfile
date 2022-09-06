FROM    debian:buster

RUN apt update -y
RUN apt upgrade -y
RUN apt install -y nginx
RUN apt install -y vim
RUN apt install -y nano

#PHP: installing fpm to process webpages and mysql to communicate with database \
    # php-fpm receive request for php files and process it and gives back the  \
    # result to nginx. Wordpress is in php so no problem with other files. \
    # it basically does what our webserv does
# RUN apt install -y php-fpm php-mysql

#ENV MYSQL_HOST=172.18.0.2
#ENV MYSQL_USER=superuser
#ENV MYSQL_PASSWORD=password
#ENV MYSQL_DB=wordpressDB

#OPENSSL - install and create self-signed key and certificate
RUN  apt install openssl

# copy wanted configuration file to the nginx
COPY conf/configuration.conf /etc/nginx/sites-avaliable/
COPY tools/nginx_entrypoint.sh /usr/bin/
###########################################################
#### FRIDAY 18:00 - we commented this lines as decided #####
#### that we create that files inside container so no need to copy
#### them from the system. its actually stupid xd ######
############################################################
#COPY conf/ssl-params.conf /etc/nginx/snippets/
#COPY conf/self-signed.conf /etc/nginx/snippets/
#COPY conf /etc/nginx/sites-avaliable
#--
# it is necesary to link the file to sites-avaliable, dunno why. File must be in both locations, it could be copied eventually but den we would have to change both of them so link works betta
# dunno why not working
# copied to entrypoint
# RUN ln -s /etc/nginx/sites-enabled/*.conf /etc/nginx/sites-avaliable

#this command should be run after changing config file to check if there is no errors
#moved to 
#RUN nginx -t

#must start php service
#RUN /etc/init.d/php7.3-fpm start
#ENTRYPOINT?
#dunno why not executing
ENTRYPOINT ["nginx_entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
