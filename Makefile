.DEFAULT_GOAL := help

MAKEFLAGS += $(if $(value VERBOSE),,--no-print-directory)

###
# ENVIRONMENT VARIABLES
###

# Create a dotEnv file if does not exists
$(shell test -f .env || echo "APP_ENV=dev" > .env)

# Load variables from dotEnv file
include .env
export $(shell sed 's/=.*//' .env);

###
# CONSTANTS
###

SERVICE_CADDY = caddy
SERVICE_APP   = app1

#---

WEBSITE_URL = https://localhost

#---

HOST_USER_ID    := $(shell id --user)
HOST_USER_NAME  := $(shell id --user --name)
HOST_GROUP_ID   := $(shell id --group)
HOST_GROUP_NAME := $(shell id --group --name)

#---

DOCKER_COMPOSE         = docker compose --file docker/docker-compose.yml --file docker/docker-compose.override.$(APP_ENV).yml

DOCKER_BUILD_ARGUMENTS = --build-arg="HOST_USER_ID=$(HOST_USER_ID)" --build-arg="HOST_USER_NAME=$(HOST_USER_NAME)" --build-arg="HOST_GROUP_ID=$(HOST_GROUP_ID)" --build-arg="HOST_GROUP_NAME=$(HOST_GROUP_NAME)"

DOCKER_RUN_AS_ROOT     = $(DOCKER_COMPOSE) run -it --rm $(SERVICE_APP)
DOCKER_RUN_AS_USER     = $(DOCKER_COMPOSE) run -it --rm --user $(HOST_USER_ID):$(HOST_GROUP_ID) $(SERVICE_APP)

#---

IS_INSTALLED_GUM := $(shell dpkg -s gum 2>/dev/null | grep -q 'Status: install ok installed' && echo 0 || echo 1)

###
# FUNCTIONS
###

define showInfo
	@echo ":small_orange_diamond: $(1)" | gum format -t emoji
	@echo ""
endef

define showAlert
	@echo ":heavy_exclamation_mark: $(1)" | gum format -t emoji
	@echo ""
endef

define taskDone
	@echo ""
	@echo ":small_blue_diamond: Task done!" | gum format -t emoji
	@echo ""
endef

###
# MISCELANEOUS
###

.PHONY: set-environment
set-environment:
	$(eval APP_ENV=$(shell gum choose --header "Setting up Makefile environment..." --selected "dev" "dev" "prod"))
	@gum spin --spinner dot --title "Persisting your selection..." -- sleep 1
	@sed -i 's/^APP_ENV=.*/APP_ENV=$(APP_ENV)/' .env
	$(MAKE) help

.PHONY: ensure_gum_is_installed
ensure_gum_is_installed:
	@if [ "${IS_INSTALLED_GUM}" = "1" ] ; then \
    	clear ; \
    	echo "🔸 Installing dependencies..." ; \
    	echo "" ; \
    	sudo mkdir -p /etc/apt/keyrings ; \
		curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg ; \
		echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list ; \
		sudo apt update && sudo apt install gum ; \
	fi;

.PHONY: require-confirmation
require-confirmation:
	$(eval CONFIRMATION=$(shell gum confirm "Are you sure?" && echo "Y" || echo "N"))

.PHONY: choose-service
choose-service:
	$(eval SERVICE=$(shell gum choose --header "Select a service..." --selected "app1" "app1" "caddy"))

.PHONY: exit
exit:
	$(call showInfo,"See you soon!")
	@exit 0;

.PHONY: welcome
welcome:
	$(eval SERVICES=$(shell docker ps --format '{{.Names}}'))
	@clear
	@gum style --align center --width 80 --padding "1 2" --border double --border-foreground 99 ".: AVAILABLE COMMANDS :."
	@echo ':small_blue_diamond: HOST USER ..... {{ Color "212" "0" " ($(HOST_USER_ID)) $(HOST_USER_NAME) " }}' | gum format -t emoji | gum format -t template; echo ''
	@echo ':small_blue_diamond: HOST GROUP .... {{ Color "212" "0" " ($(HOST_GROUP_ID)) $(HOST_GROUP_NAME) " }}' | gum format -t emoji | gum format -t template; echo ''
	@echo ':small_blue_diamond: ENVIRONMENT ... {{ Color "212" "0" " $(APP_ENV) " }}' | gum format -t emoji | gum format -t template; echo ''
	@echo ':small_blue_diamond: DOMAIN URL .... {{ Color "212" "0" " $(WEBSITE_URL) " }}' | gum format -t emoji | gum format -t template; echo ''
	@echo ':small_blue_diamond: SERVICE(S) .... {{ Color "212" "0" " $(SERVICES) " }}' | gum format -t emoji | gum format -t template; echo ''
	@echo ''

###
# HELP
###

.PHONY: help
help: ensure_gum_is_installed welcome
	$(eval OPTION=$(shell gum choose --height 20 --header "Choose a command..." --selected "exit" "exit" "set-environment" "build" "up" "down" "restart" "logs" "inspect" "shell" "composer-dump" "composer-install" "composer-update" "composer-require" "composer-require-dev" "get-xdebug-client-host" "check-syntax" "check-style" "fix-style" "phpstan" "test" "coverage" "install-caddy-certificate" "install-skeleton" "install-laravel" "install-symfony" "uninstall-app" "open-website"))
	@$(MAKE) ${OPTION}

###
# DOCKER RELATED
###

.PHONY: build
build:
	$(call showInfo,"Building Docker image\(s\)...")
	@COMPOSE_BAKE=true $(DOCKER_COMPOSE) build $(DOCKER_BUILD_ARGUMENTS)
	$(call taskDone)

.PHONY: up
up:
	$(call showInfo,"Starting service\(s\)...")
	@$(DOCKER_COMPOSE) up --remove-orphans --detach
	$(call taskDone)

.PHONY: down
down:
	$(call showInfo,"Starting service\(s\)...")
	@$(DOCKER_COMPOSE) down --remove-orphans
	$(call taskDone)

.PHONY: restart
restart:
	$(call showInfo,"Starting service\(s\)...")
	@$(DOCKER_COMPOSE) restart
	$(call taskDone)

.PHONY: logs
logs: choose-service
	$(call showInfo,"Exposing [ $(SERVICE) ] logs...")
	@$(DOCKER_COMPOSE) logs -f $(SERVICE)
	$(call taskDone)

.PHONY: inspect
inspect: choose-service
	$(call showInfo,"Inspecting [ $(SERVICE) ] health...")
	@docker inspect --format "{{json .State.Health}}" $(SERVICE) | jq
	$(call taskDone)

.PHONY: shell
shell:
	$(call showInfo,"Establishing a shell terminal with [ $(SERVICE_APP) ] service...")
	@$(DOCKER_RUN_AS_USER) sh
	$(call taskDone)

###
# CADDY / SSL CERTIFICATE
###

.PHONY: install-caddy-certificate
install-caddy-certificate:
	$(call showInfo,"Installing [ Caddy 20XX ECC Root ] as a valid Local Certificate Authority")
	@gum spin --spinner dot --title "Copy the root certificate from Caddy Docker container..." -- sleep 1
	@docker cp $(SERVICE_CADDY):/data/caddy/pki/authorities/local/root.crt ./caddy-root-ca-authority.crt
	@gum pager < README-CADDY.md
	$(call taskDone)

###
# APP / COMPOSER RELATED
###

.PHONY: composer-dump
composer-dump:
	$(call showInfo,"Executing [ composer dump-auto ] inside [ $(SERVICE_APP) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer dump-auto
	$(call taskDone)

.PHONY: composer-install
composer-install:
	$(call showInfo,"Executing [ composer install ] inside [ $(SERVICE_APP) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer install
	$(call taskDone)

.PHONY: composer-update
composer-update:
	$(call showInfo,"Executing [ composer update ] inside [ $(SERVICE_APP) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer update
	$(call taskDone)

.PHONY: composer-require
composer-require:
	$(call showInfo,"Executing [ composer require ] inside [ $(SERVICE_APP) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer require
	$(call taskDone)

.PHONY: composer-require-dev
composer-require-dev:
	$(call showInfo,"Executing [ composer require --dev ] inside [ $(SERVICE_APP) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer require --dev
	$(call taskDone)

###
# DEBUG
###

.PHONY: get-xdebug-client-host
get-xdebug-client-host:
	$(call showInfo,"Inspecting [ $(SERVICE_APP) ] networks settings...")
	@docker inspect --format "{{json .NetworkSettings.Networks.docker_default.Gateway}}" $(SERVICE_APP) | jq -r
	$(call taskDone)

###
# APP / QA RELATED
###

.PHONY: check-syntax
check-syntax:
	$(call showInfo,"Executing [ composer check-syntax ] inside [ $(SERVICE_APP) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer check-syntax
	$(call taskDone)

.PHONY: check-style
check-style:
	$(call showInfo,"Executing [ composer check-style ] inside [ $(SERVICE_APP) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer check-style
	$(call taskDone)

.PHONY: fix-style
fix-style:
	$(call showInfo,"Executing [ composer fix-style ] inside [ $(SERVICE_APP) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer fix-style
	$(call taskDone)

.PHONY: phpstan
phpstan:
	$(call showInfo,"Executing [ composer phpstan ] inside [ $(SERVICE_APP) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer phpstan
	$(call taskDone)

.PHONY: test
test:
	$(call showInfo,"Executing [ composer paratest ] inside [ $(SERVICE_APP) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer paratest
	$(call taskDone)

.PHONY: coverage
coverage:
	$(call showInfo,"Executing [ composer paracoverage ] inside [ $(SERVICE_APP) ] container service...")
	@$(DOCKER_RUN_AS_USER) composer paracoverage
	$(call taskDone)

###
# APP / INSTALLERS
###

.PHONY: install-skeleton
install-skeleton:
	$(call showInfo,"Installing [ PHP Skeleton ]...")
	@$(DOCKER_RUN_AS_USER) composer create-project alcidesrc/php-skeleton .
	$(call taskDone)

.PHONY: install-laravel
install-laravel:
	$(call showInfo,"Installing [ LaravelPHP ]...")
	@$(DOCKER_RUN_AS_USER) composer create-project laravel/laravel .
	$(call taskDone)

.PHONY: install-symfony
install-symfony:
	$(call showInfo,"Installing [ SymfonyPHP ]...")
	@$(DOCKER_RUN_AS_USER) composer create-project symfony/skeleton .
	$(call taskDone)

.PHONY: uninstall-app
uninstall-app: require-confirmation
	@if [ "${CONFIRMATION}" = "Y" ] ; then \
    	gum spin --spinner dot --title "Recreating application folder..." -- sleep 1 ; \
    	rm -Rf ./src ; \
		mkdir ./src ; \
	fi;
	@if [ "${CONFIRMATION}" = "N" ] ; then \
    	gum spin --spinner dot --title "Nothing to do..." -- sleep 1 ; \
	fi;
	$(MAKE) help

###
# SHORTCUTS
###

.PHONY: open-website
open-website: ## Application: opens the application URL
	$(call showInfo,"Opening the application URL...")
	@echo ""
	@xdg-open $(WEBSITE_URL)
	@$(call showAlert,"Press Ctrl+C to resume your session")
	$(call taskDone)
