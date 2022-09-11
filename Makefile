all: bind_mount up

build:
	@docker-compose -f srcs/docker-compose.yml build
up:
	@docker-compose -f srcs/docker-compose.yml up
start:
	@docker-compose -f srcs/docker-compose.yml start
stop:
	@docker-compose -f srcs/docker-compose.yml stop
restart: stop
	@docker-compose -f srcs/docker-compose.yml up -d
down:
	@docker-compose -f srcs/docker-compose.yml down

destroy:
	@docker-compose -f srcs/docker-compose.yml down -v
clean:
	@docker-compose -f srcs/docker-compose.yml down
fclean: destroy
	@docker system prune -af
	@docker image prune -af
	@sudo rm -fr /home/$(USER)/data/mariadb /home/przemek/data/nginx_wordpress

re: fclean all

bind_mount:
	@mkdir -pv /home/$(USER)/data/mariadb
	@mkdir -pv /home/$(USER)/data/nginx_wordpress


.PHONY: all clean fclean re build up start stop restart down destroy bind_mount