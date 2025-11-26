.PHONY: help build up shell bootstrap lock local-shell

UID := $(shell id -u)
GID := $(shell id -g)
USER := $(shell id -un)

export UID
export GID
export USER

DOCKER_COMPOSE_CMD := $(shell if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then echo "docker compose"; elif command -v docker-compose >/dev/null 2>&1; then echo "docker-compose"; else echo ""; fi)
HAS_DOCKER := $(shell if [ -n "$(DOCKER_COMPOSE_CMD)" ]; then echo 1; else echo 0; fi)

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
		$(DOCKER_COMPOSE_CMD) build; \
		else \
			echo "Docker/Compose not available on this host."; \
			echo "Install Docker + Compose with either:"; \
			echo "  sudo apt update && sudo apt install -y docker.io docker-compose-plugin"; \
			echo "      (may require Docker's apt repo on some distros)"; \
			echo "  # OR the legacy CLI"; \
			echo "  sudo apt update && sudo apt install -y docker.io docker-compose"; \
			echo "  sudo systemctl enable --now docker"; \
			echo "  sudo usermod -aG docker $$USER && newgrp docker"; \
			echo "Then rerun: make build"; \
			echo "Alternatively, run './scripts/make_local.sh' to install SWI-Prolog and Python deps for a host-only workflow, and use 'make local-shell'."; \
		fi

up: build
	@if [ "$(HAS_DOCKER)" -eq 1 ]; then \
		$(DOCKER_COMPOSE_CMD) run --rm petta-dev; \
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
