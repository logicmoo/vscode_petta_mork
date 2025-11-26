.PHONY: help build up shell bootstrap lock

help:
	@echo "Targets:"
	@echo "  build     - Build the dev container image"
	@echo "  up        - Run dev container (interactive)"
	@echo "  bootstrap - Clone/update upstream repos"
	@echo "  lock      - Lock upstreams.list to current SHAs"
	@echo "  shell     - Open a shell in the dev container"

build:
	docker compose build

up: build
	docker compose run --rm petta-dev

shell: up

bootstrap:
	./scripts/bootstrap_repos.sh

lock:
	./scripts/lock_repos.sh
