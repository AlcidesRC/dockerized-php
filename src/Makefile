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
	@echo "${RESET}"
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "· ${YELLOW}%-30s${RESET} %s\n", $$1, $$2}'
	@echo ""

###
# FUNCTIONS
###

require-%:
	@if [ -z "$($(*))" ] ; then \
		echo "" ; \
		echo " ${RED}⨉${RESET} Parameter [ ${YELLOW}${*}${RESET} ] is required!" ; \
		echo "" ; \
		echo " ${YELLOW}ℹ${RESET} Usage [ ${YELLOW}make COMMAND${RESET} ${RED}${*}=${RESET}${YELLOW}xxxxxx${RESET} ]" ; \
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

define pad
	$(shell printf "%-$(1)s" " ")
endef

###
# COMPOSER
###

.PHONY: composer-dump
composer-dump: ## Composer: executes <composer dump-auto> inside the container
	$(call showInfo,"Executing \<composer dump-auto\>...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer dump-auto
	$(call taskDone)

.PHONY: composer-install
composer-install: ## Composer: executes <composer install> inside the container
	$(call showInfo,"Executing \<composer install\>...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer install
	$(call taskDone)

.PHONY: composer-remove
composer-remove: require-package ## Composer: executes <composer remove> inside the container
	$(call showInfo,"Executing \<composer remove\>...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer remove
	$(call taskDone)

.PHONY: composer-require-dev
composer-require-dev: ## Composer: executes <composer require --dev> inside the container
	$(call showInfo,"Executing \<composer require --dev\>...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer require --dev
	$(call taskDone)

.PHONY: composer-require
composer-require: ## Composer: executes <composer require> inside the container
	$(call showInfo,"Executing \<composer require\>...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer require
	$(call taskDone)

.PHONY: composer-update
composer-update: ## Composer: executes <composer update> inside the container
	$(call showInfo,"Executing \<composer update\>...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer update
	$(call taskDone)

###
# QA
###

.PHONY: check-syntax
check-syntax: ## QA: executes <check-syntax> inside the container
	$(call showInfo,"Executing \<composer check-syntax\>...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer check-syntax
	$(call taskDone)

.PHONY: check-style
check-style: ## QA: executes <check-style> inside the container
	$(call showInfo,"Executing \<composer check-style\>...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer check-style
	$(call taskDone)

.PHONY: fix-style
fix-style: ## QA: executes <fix-style> inside the container
	$(call showInfo,"Executing \<composer fix-style\>...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer fix-style
	$(call taskDone)

.PHONY: phpstan
phpstan: ## QA: executes <composer phpstan> inside the container
	$(call showInfo,"Executing \<composer phpstan\>...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer phpstan
	$(call taskDone)

.PHONY: tests
test: ## QA: executes <composer paratest> inside the container
	$(call showInfo,"Executing \<composer paratest\>...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer test
	$(call taskDone)

.PHONY: coverage
coverage: ## QA: executes <composer paracoverage> inside the container
	$(call showInfo,"Executing \<composer paracoverage\>...")
	@echo ""
	@$(DOCKER_RUN_AS_USER) composer coverage
	$(call taskDone)
