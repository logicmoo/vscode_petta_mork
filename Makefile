.PHONY: help build up shell bootstrap lock local-shell

UID := $(shell id -u)
GID := $(shell id -g)
USER := $(shell id -un)

export UID
export GID
export USER

HAS_DOCKER := $(shell command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1 && echo 1 || echo 0)

help:
	@echo "Targets:"
	@echo "  build     - Build the dev container image"
	@echo "  up        - Run dev container (interactive)"
	@echo "  bootstrap - Clone/update upstream repos"
	@echo "  lock      - Lock upstreams.list to current SHAs"
	@echo "  shell     - Open a shell in the dev container"
	@echo "  local-shell - Open a host shell with optional .venv activation"

build:
	@if [ "$(HAS_DOCKER)" -eq 1 ]; then \
		docker compose build; \
	else \
		echo "Docker Compose not available; skipping container build."; \
	fi

up: build
	@if [ "$(HAS_DOCKER)" -eq 1 ]; then \
		docker compose run --rm petta-dev; \
	else \
		echo "Docker Compose not available; starting host shell instead."; \
		./scripts/local_shell.sh; \
	fi

shell: up

local-shell:
	./scripts/local_shell.sh

bootstrap:
	./scripts/bootstrap_repos.sh

lock:
	./scripts/lock_repos.sh
