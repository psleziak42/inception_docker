#THIS IS DOCKERFILE it is a cookbook for the image
# TALK ABOUT GOOD PRACTICE WITH USING DOCKERFILE
FROM    debian:buster

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y nginx
RUN apt-get install -y vim
RUN apt-get install -y nano

#OPENSSL - install and create self-signed key and certificate
RUN  apt-get install openssl

# copy wanted configuration file to the nginx
COPY conf/configuration.conf /etc/nginx/sites-avaliable/
COPY tools/nginx_entrypoint.sh /usr/bin/

ENTRYPOINT ["nginx_entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
