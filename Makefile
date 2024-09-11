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

SERVICE_APP   = app
SERVICE_CADDY = caddy

#---

WEBSITE_URL = https://website.localhost

#---

HOST_USER_ID    := $(shell id --user)
HOST_USER_NAME  := $(shell id --user --name)
HOST_GROUP_ID   := $(shell id --group)
HOST_GROUP_NAME := $(shell id --group --name)

#---

DOCKER_COMPOSE         = docker compose --file docker-compose.yml --file docker-compose.override.$(env).yml

DOCKER_BUILD_ARGUMENTS = --build-arg="HOST_USER_ID=$(HOST_USER_ID)" --build-arg="HOST_USER_NAME=$(HOST_USER_NAME)" --build-arg="HOST_GROUP_ID=$(HOST_GROUP_ID)" --build-arg="HOST_GROUP_NAME=$(HOST_GROUP_NAME)"

DOCKER_RUN             = $(DOCKER_COMPOSE) run --rm $(SERVICE_APP)
DOCKER_RUN_AS_USER     = $(DOCKER_COMPOSE) run --rm --user $(HOST_USER_ID):$(HOST_GROUP_ID) $(SERVICE_APP)

###
# FUNCTIONS
###

require-%:
	@if [ -z "$($(*))" ] ; then \
		echo "" ; \
		echo " ${RED}⨉${RESET} Parameter [ ${YELLOW}${*}${RESET} ] is required!" ; \
		echo "" ; \
		echo " ${YELLOW}ℹ${RESET} Usage [ ${YELLOW}make <command>${RESET} ${RED}${*}=${RESET}${YELLOW}xxxxxx${RESET} ]" ; \
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
	@echo " ${YELLOW}ℹ${RESET}  $(1) $(2)"
endef

# $(1)=TEXT $(2)=EXTRA
define showAlert
	@echo " ${RED}!${RESET}  $(1) $(2)"
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
	@echo "${BLACK}·${RESET} ${MAGENTA}USER${BLACK} ......... ${WHITE}(${CYAN}$(HOST_USER_ID)${WHITE})${BLACK} ${CYAN}$(HOST_USER_NAME)${BLACK}"
	@echo "${BLACK}·${RESET} ${MAGENTA}GROUP${BLACK} ........ ${WHITE}(${CYAN}$(HOST_GROUP_ID)${WHITE})${BLACK} ${CYAN}$(HOST_GROUP_NAME)${BLACK}"
	@echo "${BLACK}·${RESET} ${MAGENTA}SERVICE(s)${BLACK} ... ${CYAN}$(SERVICE_APP)${BLACK}, ${CYAN}$(SERVICE_CADDY)${BLACK}"
	@echo "${RESET}"
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "${BLACK}·${RESET} ${YELLOW}%-35s${RESET} %s\n", $$1, $$2}'
	@echo ""

###
# DOCKER RELATED
###

.PHONY: build
build: ## Docker: builds the service <env=[dev|prod]>
	@$(eval env ?= 'dev')
	@$(DOCKER_COMPOSE) build $(DOCKER_BUILD_ARGUMENTS)
	$(call taskDone)

.PHONY: up
up: ## Docker: starts the service <env=[dev|prod]>
	@$(eval env ?= 'dev')
	@$(DOCKER_COMPOSE) up --remove-orphans --detach
	$(call taskDone)

.PHONY: restart
restart: ## Docker: restarts the service <env=[dev|prod]>
	@$(eval env ?= 'dev')
	@$(DOCKER_COMPOSE) restart
	$(call taskDone)

.PHONY: down
down: ## Docker: stops the service <env=[dev|prod]>
	@$(eval env ?= 'dev')
	@$(DOCKER_COMPOSE) down $(DOCKER_COMPOSE_FILES) --remove-orphans
	$(call taskDone)

.PHONY: logs
logs: ## Docker: exposes the service logs <env=[dev|prod]>
	@$(eval env ?= 'dev')
	@$(eval service ?= 'app')
	@$(DOCKER_COMPOSE) logs $(service)
	$(call taskDone)

.PHONY: shell
shell: ## Docker: establish a shell session into main container
	@$(eval env ?= 'dev')
	$(DOCKER_RUN_AS_USER) sh

###
# CADDY
###

.PHONY: install-caddy-certificate
install-caddy-certificate: up ## Setup: extracts the Caddy Local Authority certificate
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
	$(call showInfo,"Installing PHP Skeleton")
	@$(eval env ?= 'dev')
	$(DOCKER_RUN_AS_USER) composer create-project alcidesrc/php-skeleton .
	$(call taskDone)

.PHONY: install-laravel
install-laravel: ## Application: installs Laravel
	$(call showInfo,"Installing Laravel")
	@$(eval env ?= 'dev')
	$(DOCKER_RUN_AS_USER) composer create-project laravel/laravel .
	$(call taskDone)

.PHONY: install-symfony
install-symfony: ## Application: installs Symfony
	$(call showInfo,"Installing Symfony")
	@$(eval env ?= 'dev')
	$(DOCKER_RUN_AS_USER) composer create-project symfony/skeleton .
	$(call taskDone)

.PHONY: uninstall
uninstall: require-confirm ## Application: removes the PHP application
	$(call showInfo,"Uninstalling PHP Application")
	@rm -Rf ./src && mkdir ./src
	$(call taskDone)
