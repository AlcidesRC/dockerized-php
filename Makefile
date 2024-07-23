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

DOCKER_COMPOSE_COMMAND = docker compose

DOCKER_RUN             = $(DOCKER_COMPOSE_COMMAND) run --rm $(SERVICE_APP)
DOCKER_RUN_AS_USER     = $(DOCKER_COMPOSE_COMMAND) run --rm --user $(HOST_USER_ID):$(HOST_GROUP_ID) $(SERVICE_APP)

DOCKER_EXEC            = $(DOCKER_COMPOSE_COMMAND) exec $(SERVICE_APP)
DOCKER_EXEC_AS_USER    = $(DOCKER_COMPOSE_COMMAND) exec --user $(HOST_USER_ID):$(HOST_GROUP_ID) $(SERVICE_APP)

DOCKER_BUILD_ARGUMENTS = --build-arg="HOST_USER_ID=$(HOST_USER_ID)" --build-arg="HOST_USER_NAME=$(HOST_USER_NAME)" --build-arg="HOST_GROUP_ID=$(HOST_GROUP_ID)" --build-arg="HOST_GROUP_NAME=$(HOST_GROUP_NAME)"

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

###
# HELP
###

.PHONY: help
help:
	@clear
	@echo "╔══════════════════════════════════════════════════════════════════════════════╗"
	@echo "║                                                                              ║"
	@echo "║                           ${YELLOW}.:${RESET} AVAILABLE COMMANDS ${YELLOW}:.${RESET}                           ║"
	@echo "║                                                                              ║"
	@echo "╚══════════════════════════════════════════════════════════════════════════════╝"
	@echo ""
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "· ${YELLOW}%-30s${RESET} %s\n", $$1, $$2}'
	@echo ""

###
# DOCKER RELATED
###

.PHONY: build
build: ## Docker: builds the service
	@$(DOCKER_COMPOSE_COMMAND) build $(DOCKER_BUILD_ARGUMENTS)
	$(call taskDone)

.PHONY: up
up: ## Docker: starts the service
	@$(DOCKER_COMPOSE_COMMAND) up --remove-orphans --detach
	$(call taskDone)

.PHONY: restart
restart: ## Docker: restarts the service
	@$(DOCKER_COMPOSE_COMMAND) restart
	$(call taskDone)

.PHONY: down
down: ## Docker: stops the service
	@$(DOCKER_COMPOSE_COMMAND) down --remove-orphans
	$(call taskDone)

.PHONY: logs
logs: ## Docker: exposes the service logs
	@$(DOCKER_COMPOSE_COMMAND) logs
	$(call taskDone)

.PHONY: bash
bash: ## Docker: establish a bash session into main container
	$(DOCKER_RUN_AS_USER) bash

###
# CADDY
###

.PHONY: extract-caddy-certificate
extract-caddy-certificate: up ## Setup: extracts the Caddy Local Authority certificate
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
# MISCELANEOUS
###

.PHONY: show-context
show-context: ## Setup: show context
	$(call showInfo,"Showing context")
	@echo "    · Domain     : ${YELLOW}${WEBSITE_URL}${RESET}"
	@echo "    · Host user  : (${YELLOW}${HOST_USER_ID}${RESET}) ${YELLOW}${HOST_USER_NAME}${RESET}"
	@echo "    · Host group : (${YELLOW}${HOST_GROUP_ID}${RESET}) ${YELLOW}${HOST_GROUP_NAME}${RESET}"
	@echo "    · Service(s) : ${YELLOW}${SERVICE_APP}${RESET}, ${YELLOW}${SERVICE_CADDY}${RESET}"
	@echo ""
	$(call showInfo,"SSL")
	@echo "    · Please execute [ ${YELLOW}make install-caddy-certificate${RESET} ] to register ${CYAN}Caddy's Root Certificate${RESET} on your browser"
	$(call taskDone)

###
# APPLICATION
###

.PHONY: uninstall
uninstall: require-confirm ## Application: removes the PHP application
	$(call showInfo,"Uninstalling PHP Application")
	@find ./src -type f -delete
	@rm -Rf ./src/*
	$(call taskDone)

.PHONY: install-skeleton
install-skeleton: ## Application: installs PHP Skeleton
	$(call showInfo,"Installing PHP Skeleton")
	$(DOCKER_RUN_AS_USER) composer create-project fonil/php-skeleton .
	$(call taskDone)

.PHONY: install-laravel
install-laravel: ## Application: installs Laravel
	$(call showInfo,"Installing Laravel")
	$(DOCKER_RUN_AS_USER) composer create-project laravel/laravel .
	$(call taskDone)

.PHONY: install-symfony
install-symfony: ## Application: installs Symfony
	$(call showInfo,"Installing Symfony")
	$(DOCKER_RUN_AS_USER) composer create-project symfony/skeleton .
	$(call taskDone)
