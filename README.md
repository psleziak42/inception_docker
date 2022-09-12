# Inception. That Means Docker!
### Why Docker?

## The Objective

The objective of this task is to set up system that can run wordpress using docker-compose.yaml.
For this purpose there are created 3 containers:
- mariadb - database
- wordpress - contains php-fpm that processes .php requests coming from the client via reverse proxy.
- nginx - working as reverse proxy, being only entrypoint to the system via port 443 (secure connection)
and 2 volumes:
- one to keep database persistency
- second to share data between wordpress and nginx

All the images must be based on minimal OS like Linux Alpine or Debian Buster(my choice) and follow with the instalation
of all the dependencies necessary for a process to run. I think the idea here is similar to create Yocto Linux, where we
have bitbake files that do similar thing. The difference is that Yocto is full Linux Distribution built from scratch and
Docker container is using running system kernel as a base.

"Normal ;)" people use ready images based on docker-hub. It is however worth to mention that those images also
don't come out of the blue. Any ready image also contains "FROM" command that indicates it is based on another
image - for example nginx is based on Alpine and Alpine is an Image created from Scratch. 


### _What is a Dockerfile?_
A Dockerfile is simply a text-based script of instructions that is used to create a container image. We could
simplify saying that Dockefile is a receipe for our image.

### _Commands used inside Dockerfile and their meaning:_

Please have in mind that this list contains only what I used during the project. Full documentation can be found
at [docker_instructions](https://docs.docker.com/engine/reference/builder/).

###### _FROM <image>_
Search for an image in the docker-hub repository. Downloaded becomes base image for following instructions.

###### _RUN <command>_
Used to install DEPENDENCIES.
Imagine you have fresh Ubuntu instalation that does not contain Vim, Nano, Sudo. With RUN I first update and upgrade the
system and later install all the dependencies. It is used to download wordpress, php-fpm, openssl, mariadb etc.

In my case (and I think good practice) DEPENDENCIES are made in a DOCKERFILE.

###### _COPY <src> <dest>_
Well it copies folder/file from host to the container: COPY <scr> <dest>.
I use it to copy ready configuration files and entrypoint.sh scripts.

###### _ENTRYPOINT ["/path/to/entrypoint.sh"]_
Entrypoint should specify path to <dest> (see COPY instruction). If put under $PATH only script name is required.
AS DOCKERFILE IS USED TO INSTALL IMAGE dependencies ENTRYPOINT IS USED TO configure THE CONTAINER.

How to think about ENTRYPOINT*?
Think about it as a place where we put instructions that are suppose to configure the environment inside container
eg. move files, change script permissions, owners, set up installed database etc.

*more detailed info inside wordpress/Dockerfile.

###### _CMD ["process", "run", "in", "foreground"]_
CMD* is the default command to run inside the container. It must be blocking command that runs in the fg.
Blocking command is the one that expects some input from the user like grep, cat, also tail -f is very
popular pattern here. In case of this project those shortcuts were prohibited. As Docker Container should
represent an application, that app should be responsible to decide weather to terminate the container or
keep it alive.  This is why you may see: CMD ["nginx", "-g", "daemon off;"].

Worth to mention that CMD work like argument(s) to entrypoint script. As example:
```sh
wordpress_entrypoint.sh /usr/sbin/php-fpm7.3 --nodaemonize
```

*more detailed info inside wordpress/Dockerfile

#### _Dockerfile Good Practice_
Image is made from layers. Layer is each command in Dockerfile. Once layer changes all downstream layers must recreate.
Once the image is being created, all the commands are run one after another*. But when we have an image and want to
update it, it uses cache until it finds a change. So the good practice is to put all the instructions that remain
unlikely to be changed: installations, downloads (usually RUN commands) on top and instructions like COPY, ENV that
transports the files or update Environmental variables on the bottom.

*entrypoint and cmd are small exceptions that is explained inside wordpress/Dockerfile. In short terms entrypoint
is a first thing that is run on a WORKING CONTAINER - and working container is after image is created or when
docker compose file finish execution.

### _What is a Docker Image?_

Container Image is created from Dockerfile with a command:
```sh
docker build [OPTIONS] path/to/the/Dockerfile
docker build -t mariadb .
```
Docker Image contains all the necessary environment to run an application. It is our application.

### _What is a Container?_

Now when we have image we can finally create a Container with a command:
```sh
docker run [OPTIONS] IMAGE [COMMAND(entrypoint)] [ARG(cmd)]
docker run -d --name wordpress_ wordpress
```
Container is just another process on our machine, that is isolated from host system (and) other containers (unless
they are present in the same network what actually happen by default). If someone wonders what is a process...

Imagine you compile a program that displays "hello world" and run sleep(10). If you execute it in the background
and type ps in command line you will see new process running, that will last 10 seconds and it will disappear.
So again CONTAINER is a PROCESS. That means it will do what we ask it to do and "disappear". This is a problem for
beginners (hehe) to understand "why this happens". Dockerfile pull an image, execute CMD ["echo", "hello world"]
and exits - we cannot attach to it, run a terminal to see what is inside. And this is the reason.
IT DOES THE JOB AND QUITS ~ Diogo Coelho Cavaleiro.

ONE exemple from my fight vs Docker
```sh
docker run [OPTIONS] IMAGE <COMMAND(entrypoint)> [ARG(cmd)]

CMD ["nginx", "-g", "daemon off;"] - inside Dockerfile
docker run -p 4040:80 -it INCEPTION_NGINX <> [bash]
```
What happened above: "[bash]" override CMD in Dockerfile and container launched with command bash. When it was launched
and I tried to access localhost:4040 from the browser it was failing. Why? Because nginx daemon was not running inside
the container! So when i run nginx -g 'daemon off;' then it was possible to connect! Now VERY IMPORTANT! 
WE SHOULD FIRST RUN THE CONTAINER AS IT IS AND ONLY LATER ATTACH TO ITS TERMINAL WITH EXEC IF WE WANT TO MAKE SOME
CHANGES!!! THIS WAY IT WILL SERVE THE CONTENT AND WE MAY STILL WONDER AROUND.
We can exit this terminal and the container still runs!

```sh
docker exec -it [container id/name] [bash]
```


##### _Everything inside one container or each app in separate container?_

The question arises due past 42's project "ft_server" which was very similar with this difference that all the system
was placed inside one container. In that case it would be similar as having separate computer (similar concept to VM)
that hosts everything together. I mess a bit in the internet and found the same questions with few reasons why it is
better to keep processes separated, that I present below. Personally I have not enough experience to debate.
- We may like to scale one app more often than another (eg frontend different than database)

- Separate containers let us verson and update versions in isolations (so if im correct, database:1.0 but node:2.1 - reflecting
changes that were done)

- Maybe we need container for the database locally, but it will be different database when sending for production. So we can only
send an app without database. Things are separated and isolated.

- !!Container only starts one process!! So if you have to start database and nginx it is becoming more complex.

### _What is Volume?_ - study it a bit more!
The legend says that when you run a container, make some updates then stop it and start again that updates should
not be present. But in that case it's not true, unless we wipe off all the info about container and run it again.
In the 2nd case volumes can be usefull as they will persist the data, unless they were not deleted also. 

Good usage of using the volumes is to share the data between host and the container. This is done with bind volumes.

There are 3 type of volumes:
1. named [volume_name:/container/destination/path]: 
   Volume is created inside docker folder in the filesystem with a provided name. All the data will be stored and updated
   there. I tried to access it from host system and it was impossible. So we cant see the data there.
2. unnamed [:/container/destination/path]
   Volume is created inside docker folder in the filesystem withOUT a provided name. All the data will be stored and
   updated there. I tried to access it from host system and it was impossible. So we cant see the data there.
3. bind [host/destination/path:/container/destination/path]
   I think it is the most cool. We can create the folder on the host system and bind it with the location inside
   container. Any file updated in the host is visible in the container and vice versa. This way we may work inside
   container without attaching to it.


### _What is Docker Network?_
By default we have 3 networks and by default all containers belongs to the same network. In our task we had to create
extra network and put our containers there to be visible for each other. It was done inside docker-compose. Important
note is that created network must be present under every container, otherwise they will be assigned to default one.

### _Docker Compose_
Docker compose is a yaml file that serves to automate the whole process of running containers. Imagine you have 100 of
them and must run each image and create each container separately and then remember which port is open where etc. With
docker-compose.yml it is all automated. One command docker compose up we create all listed services (containers), but
also network(s), volume(s) etc. Some instructions like environment/expose could be also placed inside Dockerfile. At
this point of my journey I would say to put DEPENDENCIES in the Dockerfile, CONFIGURATION in entrypoint.sh and all
the rest is handy to have with docker-compose which will be our main file from now on.

### Missing commands and bash commands, info about .env file maybe some info about configuration but its already a lot.

[magic behind docker](https://www.youtube.com/watch?v=-YnMr1lj4Z8&t=368s)
[connection between containers](https://www.tutorialworks.com/container-networking/)

[https explained in general](https://www.youtube.com/watch?v=T4Df5_cojAs)
[https explained in detail](https://www.youtube.com/watch?v=-f4Gbk-U758)
[nginx w/ certificate and 443](https://mindsers.blog/post/https-using-nginx-certbot-docker/)

[security headers and clickjacking](https://www.freecodecamp.org/news/docker-nginx-letsencrypt-easy-secure-reverse-proxy-40165ba3aee2/)