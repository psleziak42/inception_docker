# inception_docker
[connection between containers](https://www.tutorialworks.com/container-networking/)
[magic behind docker](https://www.youtube.com/watch?v=-YnMr1lj4Z8&t=368s)

Why command must be run in foreground?
Read about that mounted volumes
do env variables

how to delete latest tag from image?
latest is created autoamtically even if
name is specified
https://vsupalov.com/docker-latest-tag/

env vs arg
https://vsupalov.com/docker-arg-env-variable-guide/


make fclean
    docker compose down
    docker system prune -f -v $(docker volumes -q???)
    docker rmi -f $(docker images -q)
    docker volume prune -f (usun volume nie tylko wyczysc)

DOCKERIGNORE - how to ignore .env file?