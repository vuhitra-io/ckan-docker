.PHONY: all help build build-all push install demo

SHELL := /bin/bash
DEMO_SCRIPT_PATH := ./ckan/sh/do_initialize.sh

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
	docker exec -d ckan-dev /root/watch_sync.sh

ignite:
	docker exec -ti ckan-dev /root/do_ignite.sh

demo:
	@echo "Running initialization script..."
	@if [ -f $(DEMO_SCRIPT_PATH) ]; then \
		bash $(DEMO_SCRIPT_PATH); \
	else \
		echo "Error: Script not found at $(SCRIPT_PATH)"; \
		exit 1; \
	fi

pre-start: sync ignite
all: destroy build up pre-start auto-sync
rebuild: build up
restart: down up ignite auto-sync

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