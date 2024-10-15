.PHONY: all help build build-all push install

SHELL := /bin/bash

build:
	docker compose -f docker-compose.dev.yml build

up:
	docker compose -f docker-compose.dev.yml up -d

down:
	docker compose -f docker-compose.dev.yml down

re: up down

destroy:
	docker compose -f docker-compose.dev.yml down -v

install:
	@echo "Installing extensions..."
	./copy_extensions.sh
	docker compose exec ckan-dev /usr/local/bin/install-extensions.sh

all: build compose install
run: compose install

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