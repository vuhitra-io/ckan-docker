.PHONY: all help build build-all push install

SHELL := /bin/bash

build:
	docker compose -f docker-compose.dev.yml build
	docker compose -f docker-compose.dev.yml up -d

down:
	docker compose -f docker-compose.dev.yml down -v

install:
	docker cp ./ckan/extensions/* ckan-dev:/srv/app/src_extensions
	docker compose exec ckan-dev /usr/local/bin/install-extensions.sh

all: build install

help:
	@echo "Available targets:"
	@echo "  build       - Build and start the Docker containers"
	@echo "  install     - Copy extensions and install them in the CKAN container"
	@echo "  all         - Build and install (default)"
	@echo "  help        - Show this help message"

build-all:
	@echo "build-all target not implemented"

push:
	@echo "push target not implemented"