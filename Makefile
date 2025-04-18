.DEFAULT_GOAL := help

###
# CONSTANTS
###

ifneq (,$(findstring xterm,$(TERM)))
	BLACK   := $(shell tput -Txterm setaf 0)
	RED     := $(shell tput -Txterm setaf 1)
	GREEN   := $(shell tput -Txterm setaf 2)
	YELLOW  := $(shell tput -Txterm setaf 3)
	BLUE    := $(shell tput -Txterm setaf 4)
	MAGENTA := $(shell tput -Txterm setaf 5)
	CYAN    := $(shell tput -Txterm setaf 6)
	WHITE   := $(shell tput -Txterm setaf 7)
	RESET   := $(shell tput -Txterm sgr0)
else
	BLACK   := ""
	RED     := ""
	GREEN   := ""
	YELLOW  := ""
	BLUE    := ""
	MAGENTA := ""
	CYAN    := ""
	WHITE   := ""
	RESET   := ""
endif

#---

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

DOCKER_COMPOSE         = docker compose --file docker/docker-compose.yml --file docker/docker-compose.override.$(env).yml

DOCKER_BUILD_ARGUMENTS = --build-arg="HOST_USER_ID=$(HOST_USER_ID)" --build-arg="HOST_USER_NAME=$(HOST_USER_NAME)" --build-arg="HOST_GROUP_ID=$(HOST_GROUP_ID)" --build-arg="HOST_GROUP_NAME=$(HOST_GROUP_NAME)"

DOCKER_RUN_AS_ROOT     = $(DOCKER_COMPOSE) run -it --rm $(SERVICE_APP)
DOCKER_RUN_AS_USER     = $(DOCKER_COMPOSE) run -it --rm --user $(HOST_USER_ID):$(HOST_GROUP_ID) $(SERVICE_APP)

###
# FUNCTIONS
###

require-%:
	@if [ -z "$($(*))" ] ; then \
		echo "" ; \
		echo " ${RED}⨉${RESET} Parameter [ ${YELLOW}${*}${RESET} ] is required!" ; \
		echo "" ; \
		echo " ${YELLOW}ℹ${RESET} Usage [ ${YELLOW}make <command>${RESET} ${RED}${*}=${RESET}${YELLOW}xxxx${RESET} ]" ; \
		echo "" ; \
		exit 1 ; \
	fi;

define taskDone
	@echo ""
	@echo " ${GREEN}✓${RESET}  ${GREEN}Task done!${RESET}"
	@echo ""
endef

# $(1)=TEXT $(2)=EXTRA
define showInfo
	@echo " ${YELLOW}ℹ${RESET}  $(1) $(2)" | sed "s/\((.*)\)/\1/g"
endef

# $(1)=TEXT $(2)=EXTRA
define showAlert
	@echo " ${RED}!${RESET}  $(1) $(2)" | sed "s/\((.*)\)/\1/g"
endef

# $(1)=NUMBER $(2)=TEXT
define orderedList
	@echo ""
	@echo " ${CYAN}$(1).${RESET}  ${CYAN}$(2)${RESET}"
	@echo ""
endef

define pad
	$(shell printf "%-$(1)s" " ")
endef

###
# HELP
###

.PHONY: help
help:
	@clear
	@echo "${BLACK}"
	@echo "╔════════════════════════════════════════════════════════════════════════════════════════════════════════╗"
	@echo "║ $(call pad,96) ║"
	@echo "║ $(call pad,32) ${YELLOW}.:${RESET} AVAILABLE COMMANDS ${YELLOW}:.${BLACK} $(call pad,32) ║"
	@echo "║ $(call pad,96) ║"
	@echo "╚════════════════════════════════════════════════════════════════════════════════════════════════════════╝"
	@echo "${BLACK}·${RESET} ${MAGENTA}DOMAIN(s)${BLACK} .... ${CYAN}$(WEBSITE_URL)${BLACK}"
	@echo "${BLACK}·${RESET} ${MAGENTA}SERVICE(s)${BLACK} ... ${CYAN}$(shell docker ps --format "{{.Names}}")${BLACK}"
	@echo "${BLACK}·${RESET} ${MAGENTA}USER${BLACK} ......... ${WHITE}(${CYAN}$(HOST_USER_ID)${WHITE})${BLACK} ${CYAN}$(HOST_USER_NAME)${BLACK}"
	@echo "${BLACK}·${RESET} ${MAGENTA}GROUP${BLACK} ........ ${WHITE}(${CYAN}$(HOST_GROUP_ID)${WHITE})${BLACK} ${CYAN}$(HOST_GROUP_NAME)${BLACK}"
	@echo "${RESET}"
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "${BLACK}·${RESET} ${YELLOW}%-35s${RESET} %s\n", $$1, $$2}'
	@echo ""

###
# DOCKER RELATED
###

.PHONY: build
build: ## Docker: builds service(s) image(s) <env=[dev|prod]>
	@$(eval env ?= 'dev')
	$(call showInfo,"Building Docker image\(s\)...")
	@echo ""
	@COMPOSE_BAKE=true $(DOCKER_COMPOSE) build $(DOCKER_BUILD_ARGUMENTS)
	$(call taskDone)

.PHONY: up
up: ## Docker: starts service(s) <env=[dev|prod]>
	@$(eval env ?= 'dev')
	$(call showInfo,"Starting service\(s\)...")
	@echo ""
	@$(DOCKER_COMPOSE) up --remove-orphans --detach
	$(call taskDone)

.PHONY: restart
restart: ## Docker: restarts service(s) <env=[dev|prod]>
	@$(eval env ?= 'dev')
	$(call showInfo,"Restarting service\(s\)...")
	@echo ""
	@$(DOCKER_COMPOSE) restart
	$(call taskDone)

.PHONY: down
down: ## Docker: stops service(s) <env=[dev|prod]>
	@$(eval env ?= 'dev')
	$(call showInfo,"Stopping service\(s\)...")
	@echo ""
	@$(DOCKER_COMPOSE) down --remove-orphans
	$(call taskDone)

.PHONY: logs
logs: ## Docker: exposes main service logs <env=[dev|prod]> <service=[app1|caddy]>
	@$(eval env ?= 'dev')
	@$(eval service ?= $(SERVICE_APP))
	$(call showInfo,"Exposing [ $(service) ] service logs...")
	@echo ""
	@$(DOCKER_COMPOSE) logs -f $(service)
	$(call taskDone)

.PHONY: shell
shell: ## Docker: establish a shell terminal with main service
	@$(eval env ?= 'dev')
	$(call showInfo,"Establishing a shell terminal with [ $(SERVICE_APP) ] service...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) sh
	$(call taskDone)

.PHONY: inspect
inspect: ## Docker: inspect the service health <service=[app1|caddy]>
	@$(eval service ?= $(SERVICE_APP))
	$(call showInfo,"Inspecting the [ $(service) ] service health...")
	@echo ""
	@docker inspect --format "{{json .State.Health}}" $(service) | jq
	@echo ""
	$(call taskDone)

###
# COMPOSER
###

.PHONY: composer-dump
composer-dump: ## Composer: executes <composer dump-auto> inside the container
	@$(eval env ?= 'dev')
	$(call showInfo,"Dumping dependencies...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer dump-auto --ansi --no-plugins --profile --classmap-authoritative --apcu --strict-psr
	$(call taskDone)

.PHONY: composer-install
composer-install: ## Composer: executes <composer install> inside the container
	@$(eval env ?= 'dev')
	$(call showInfo,"Installing a dependency...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer install --ansi --no-plugins --classmap-authoritative --audit --apcu-autoloader
	$(call taskDone)

.PHONY: composer-remove
composer-remove: require-package ## Composer: executes <composer remove> inside the container
	@$(eval env ?= 'dev')
	$(call showInfo,"Removing a dependency...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer remove --ansi --no-plugins --classmap-authoritative --apcu-autoloader --with-all-dependencies --unused
	$(call taskDone)

.PHONY: composer-require-dev
composer-require-dev: ## Composer: executes <composer require --dev> inside the container
	@$(eval env ?= 'dev')
	$(call showInfo,"Requiring a development dependency...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer require --ansi --no-plugins --classmap-authoritative --apcu-autoloader --with-all-dependencies --prefer-stable --sort-packages --dev
	$(call taskDone)

.PHONY: composer-require
composer-require: ## Composer: executes <composer require> inside the container
	@$(eval env ?= 'dev')
	$(call showInfo,"Requiring a dependency...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer require --ansi --no-plugins --classmap-authoritative --apcu-autoloader --with-all-dependencies --prefer-stable --sort-packages
	$(call taskDone)

.PHONY: composer-update
composer-update: ## Composer: executes <composer update> inside the container
	@$(eval env ?= 'dev')
	$(call showInfo,"Updating dependencies...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer update --ansi --no-plugins --classmap-authoritative --apcu-autoloader --with-all-dependencies
	$(call taskDone)

###
# QA
###

.PHONY: check-syntax
check-syntax: ## QA: Executes <composer check-syntax> inside the container
	@$(eval env ?= 'dev')
	$(call showInfo,"Check code syntax...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer check-syntax
	$(call taskDone)

.PHONY: check-style
check-style: ## QA: Executes <composer check-style> inside the container
	@$(eval env ?= 'dev')
	$(call showInfo,"Checking code style...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer check-style
	$(call taskDone)

.PHONY: fix-style
fix-style: ## QA: executes <composer fix-style> inside the container
	@$(eval env ?= 'dev')
	$(call showInfo,"Fixing code style...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer fix-style
	$(call taskDone)

.PHONY: phpstan
phpstan: ## QA: executes <composer phpstan> inside the container
	@$(eval env ?= 'dev')
	$(call showInfo,"Executing PHPStan...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer phpstan
	$(call taskDone)

.PHONY: test
test: ## QA: executes <composer paratest>
	@$(eval env ?= 'dev')
	$(call showInfo,"Executing PHPUnit...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer paratest
	$(call taskDone)

.PHONY: coverage
coverage: ## QA: executes <composer paracoverage> inside the container
	@$(eval env ?= 'dev')
	$(call showInfo,"QA: Generating the Code Coverage report...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer paracoverage
	$(call taskDone)

###
# CADDY
###

.PHONY: install-caddy-certificate
install-caddy-certificate: up ## Setup: extracts the Caddy Local Authority certificate
	$(call showInfo,Extracting Caddy Certificate Authority file...)
	@echo ""
	@echo "How to install [ $(YELLOW)Caddy Local Authority - 20XX ECC Root$(RESET) ] as a valid Certificate Authority"
	$(call orderedList,1,"Copy the root certificate from Caddy Docker container")
	@docker cp $(SERVICE_CADDY):/data/caddy/pki/authorities/local/root.crt ./caddy-root-ca-authority.crt
	$(call orderedList,2,"Install the Caddy Authority certificate into your browser")
	@echo "$(YELLOW)Chrome-based browsers (Chrome, Brave, etc)$(RESET)"
	@echo "- Go to [ Settings / Privacy & Security / Security / Manage Certificates / Authorities ]"
	@echo "- Import [ ./caddy-root-ca-authority.crt ]"
	@echo "- Check on [ Trust this certificate for identifying websites ]"
	@echo "- Save changes"
	@echo ""
	@echo "$(YELLOW)Firefox browser$(RESET)"
	@echo "- Go to [ Settings / Privacy & Security / Security / Certificates / View Certificates / Authorities ]"
	@echo "- Import [ ./caddy-root-ca-authority.crt ]"
	@echo "- Check on [ This certificate can identify websites ]"
	@echo "- Save changes"
	@echo ""
	$(call showInfo,"For further information, please visit https://caddyserver.com/docs/running#docker-compose")
	$(call taskDone)

###
# APPLICATION
###

.PHONY: install-skeleton
install-skeleton: ## Application: installs PHP Skeleton
	@$(eval env ?= 'dev')
	$(call showInfo,"Installing PHP Skeleton...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer create-project alcidesrc/php-skeleton .
	$(call taskDone)

.PHONY: install-laravel
install-laravel: ## Application: installs Laravel
	@$(eval env ?= 'dev')
	$(call showInfo,"Installing Laravel...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer create-project laravel/laravel .
	$(call taskDone)

.PHONY: install-symfony
install-symfony: ## Application: installs Symfony
	@$(eval env ?= 'dev')
	$(call showInfo,"Installing Symfony...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer create-project symfony/skeleton .
	$(call taskDone)

.PHONY: uninstall
uninstall: require-confirm ## Application: removes the PHP application
	$(call showInfo,"Uninstalling PHP application...")
	@rm -Rf ./src && mkdir ./src
	$(call taskDone)

###
# MISCELANEOUS
###

.PHONY: open-website
open-website: ## Application: opens the application URL
	$(call showInfo,"Opening the application URL...")
	@echo ""
	@xdg-open $(WEBSITE_URL)
	@$(call showAlert,"Press Ctrl+C to resume your session")
	$(call taskDone)

.PHONY: init
init: build install-caddy-certificate open-website ## Application: initializes the application
