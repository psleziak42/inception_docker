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

#### _DELETE IT ALL!_
This will remove:
- all stopped containers
- all networks not used by at least one container
- all volumes not used by at least one container
- all images without at least one container associated to them
- all build cache - VERY IMPORTANT.
I spent time updating things in my project to establish connection between nginx and fpm and kept failing and failing
only to realize that nothing updates because it uses cache... ba dum tsss

```sh
docker stop $(docker ps -qa)
docker rm $(docker ps -qa)
docker rmi -f $(docker images -qa)
docker volume rm $(docker volume ls -q)
docker network rm $(docker network ls -q) 2>/dev/null
```
or
```sh
docker system prune -a --volumes
```

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

#### _.env file_
.env file is a common file to protect fragile data from 3rd party. In Poland we say that the darkest spot is where the
light shines the most. It may sound funny but once people focus on super-turbo-bullet-(or hacker-)proof apps, they may
forget about human errors. And if you look carefully in the repo I made that mistake too, same as some of my 42 friends,
when forgetting to .gitignore .env file before submitting project to the repo. There are github-crawlers(boots) that
just look for this type of files to get access to your app. 

So env file is used to cover any data you find fragile via MACRO. This file must be placed on the same level as
docker-compose file. In docker-compose there is "environment" indentation where we pass that macro to container's
environmental variables. Another way is to use "env_file" and just specify the path to the file - this way we get all
the macros (have in mind that only some of them may be necessary inside that particular container).


#### _docker api_
##### _The best way to check avaliable commands is to type docker image/container/etc --help. Below are just few that
I used when working on the project_

Must add word "docker" before every command presented here.
######_image:_
- build: build [-t name:tag/OPTIONS] path/do/dockerfile/
- remove: rmi [image name or $(docker images -aq) to remove all images]

######_container:_
- build: run [-d (daemon) or -it (interactive terminal) -p 4242(host:port):80(docker app port)/OPTIONS] contain. name/id
- start/stop/restart/remove: start/stop/restart/rm container name/id
  first we should stop container(s) and later remove it. But if you want to stop and remove at the same time then:
- stop+remove: rm -f(force) container name/id
- running container: ps
- existing container: ps -a
- network/volume: container inspect container name/id | grep -i "network/volume"

######_volumes:_
- create: volume create volume_name -> it is not necessary to run this command, it is better to use docker compose
- inspect: volume inspect volume_name -> gives info about the volume, including where it is stored
EXAMPLE OF USE (bind volume)
- host/folder:/destination/path/on/container/:ro - :ro/rw read-only/read-write. 
:ro means docker can't change the volume folder

######_network:_

######_attach to the container:_
This is the best way to connect to the container. First make it run (docker ps to check if it runs) and later:
```sh
docker exec -it [container id/name] [bash] mysql -p
```
I was trying many times to 'run' container wiht -it flag that first create an image and attach to it, but its
gonna mess you in the head, so its better to make it step by step.

docker exec -it [CONTAINER_NAME or ID] [CMD] mysql -p

#### _some bash commands_

- if [! - ... ] - reversion
- if [ -n ... ] - if string is null - STRING="", $STRING is null in that case.
- if [ -z ... ] - if string is not null
- if [ -d ... ] - if directory exists
- if [ -f ... ] - if file exists
-- 
```sh
bash_script.sh arg1 arg2 agr3 ... argn
```
- $0 = bash_script.sh
- $1-n = arg1-n
- $@ $* - all arguments
- $# - number of arguments (name is not counting)

- $@ - refers to all arguments (one by one)

### _Configuration_
I do not want to spend much time describing how to configure the subject. But one thing worth to mention is that
_EVERYTHING IS A FILE_. Magic no? For me it kinda was and it was 1st good time when I got to work with just files that
when changed affect functionality of the service. And in my opinion it was the most valuable lesson. Containers are
in the same network. What it means? If dont know go back to _NetPractice_. It means they can see each other and exchange
informations. But in order to do so you must properly set up listening port and ip in fpm, proxy pass to correct addres
and port, put proper credentials in fmp to connect with DB.

And if someone says this project is so easy and did it in a weekend without having previous experience, dont take it to 
yourself as I many times do, but at worse case put that -42 cheating flag on him ;). This project requires time and the
best students from 42Lisbon who assisted me can confirm that.


## CONCLUSION
Docker is not easy. Or let us put it with different words: it is not hard but on the beginning it frustrated me
enough times to write down this small tutorial, including descriptions inside documents that specified ongoing. When
starting (and sometimes even now when it comes to volumes) I had the feeling that depending from the day of the week (or
year!) it works differently. This is the reason why I think _attach to the container_ is very important tip for start:
FIND YOUR WAY OF WORKING WITH IT AND STICK TO IT. There is so many ways to achieve the same thing that the number of
paths is just confusing. You could do this project in totally different way - maybe putting more work inside Dockerfile
and resigning from entrypoint.sh or get rid of docker-compose.yaml and put "100" docker build docker run in makefile.
I chose "my" path after suggestions from other friends from 42. Much thanks here to _@dcavalei_ who gave me the most
support among others _@jpceia_, _@ricardomartins26_ and _@olbrien_ who helped me at the last stage of wordpress.

##### _First thing last:_
manuals hurt, but official docker page is almost written like a nice blog and that feeling of human softness visible
there makes me try to convince you to take a look on the official docker documentation. It will answer some of your
questions.
 
[magic behind docker](https://www.youtube.com/watch?v=-YnMr1lj4Z8&t=368s)

[connection between containers](https://www.tutorialworks.com/container-networking/)

[https explained in general](https://www.youtube.com/watch?v=T4Df5_cojAs)

[https explained in detail](https://www.youtube.com/watch?v=-f4Gbk-U758)

[nginx w/ certificate and 443](https://mindsers.blog/post/https-using-nginx-certbot-docker/)

[security headers and clickjacking](https://www.freecodecamp.org/news/docker-nginx-letsencrypt-easy-secure-reverse-proxy-40165ba3aee2/)