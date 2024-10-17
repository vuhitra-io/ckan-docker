.PHONY: all help build build-all push install

SHELL := /bin/bash

build:
	docker compose -f docker-compose.dev.yml build

up:
	docker compose -f docker-compose.dev.yml up -d

down:
	docker compose -f docker-compose.dev.yml down

destroy:
	docker compose -f docker-compose.dev.yml down -v

sync:
	docker exec -ti ckan-dev /root/do_sync.sh

auto-sync:
	docker exec -ti ckan-dev sh -c "/root/watch_sync.sh &"

ignite:
	docker exec -ti ckan-dev /root/do_ignite.sh

pre-start: sync ignite
all: destroy build up pre-start
rebuild: build up
restart: down up pre-start

help:
	@echo "Available targets:"
	@echo "  build       - Build and start the Docker containers"
	@echo "  install     - Copy extensions and install them in the CKAN container"
	@echo "  all         - Build and install (default)"
	@echo "  help        - Show this help message"

build-all:
	@echo "build-all target not implemented"

push:
	git push