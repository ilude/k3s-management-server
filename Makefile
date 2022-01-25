# lets try the new docker build system
# https://docs.docker.com/develop/develop-images/build_enhancements/
# https://www.docker.com/blog/faster-builds-in-compose-thanks-to-buildkit-support/
export DOCKER_BUILDKIT := 1
export DOCKER_SCAN_SUGGEST := false
export COMPOSE_DOCKER_CLI_BUILD := 1
export BUILDKIT_PROGRESS=plain


# define docker-compose flags for environments
development_FLAGS := 
production_FLAGS 	:= -f ./docker-compose.yml

# include .env if present
ifneq (,$(wildcard ./.env))
	include .env
	export
endif

# determine the name of the first service in the docker-compose.yml
export ATTACH_HOST := $(or $(shell awk 'f{print;f=0} /service/{f=1}' docker-compose.yml | sed -r 's/\s+|\://g'), webapp)

DEFAULT_SERVICE := $(shell docker-compose config --services 2>/dev/null | head -n 1)

# export PUID := $(shell id -u)
# export PGID := $(shell id -g)

bash: build 
	docker-compose run --rm ${DEFAULT_SERVICE} 
	docker-compose down --remove-orphans

echo:
	@echo DEFAULT_SERVICE=$(DEFAULT_SERVICE)
	@echo ATTACH_HOST=$(ATTACH_HOST)


attach: 
	docker-compose exec ${DEFAULT_SERVICE} /bin/zsh

logs:
	docker-compose logs -f

build: .env
	docker-compose build --progress=plain

.env:
	cp env.sample .env

env:
	env|sort