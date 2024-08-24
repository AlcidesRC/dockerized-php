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
	@echo "╔══════════════════════════════════════════════════════════════════════════════╗"
	@echo "║                                                                              ║"
	@echo "║                           ${YELLOW}.:${RESET} AVAILABLE COMMANDS ${YELLOW}:.${RESET}                           ║"
	@echo "║                                                                              ║"
	@echo "╚══════════════════════════════════════════════════════════════════════════════╝"
	@echo ""
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

###
# COMPOSER
###

.PHONY: composer-dump
composer-dump: ## Application: <composer dump-auto>
	$(DOCKER_RUN_AS_USER) composer dump-auto --ansi --no-plugins --profile --classmap-authoritative --apcu --strict-psr
	$(call taskDone)

.PHONY: composer-install
composer-install: ## Application: <composer install>
	$(DOCKER_RUN_AS_USER) composer install --ansi --no-plugins --classmap-authoritative --audit --apcu-autoloader
	$(call taskDone)

.PHONY: composer-remove
composer-remove: require-package ## Application: <composer remove>
	$(DOCKER_RUN_AS_USER) composer remove --ansi --no-plugins --classmap-authoritative --apcu-autoloader --with-all-dependencies --unused
	$(call taskDone)

.PHONY: composer-require-dev
composer-require-dev: ## Application: <composer require --dev>
	$(DOCKER_RUN_AS_USER) composer require --ansi --no-plugins --classmap-authoritative --apcu-autoloader --with-all-dependencies --prefer-stable --sort-packages --dev
	$(call taskDone)

.PHONY: composer-require
composer-require: ## Application: <composer require>
	$(DOCKER_RUN_AS_USER) composer require --ansi --no-plugins --classmap-authoritative --apcu-autoloader --with-all-dependencies --prefer-stable --sort-packages
	$(call taskDone)

.PHONY: composer-update
composer-update: ## Application: <composer update>
	$(DOCKER_RUN_AS_USER) composer update --ansi --no-plugins --classmap-authoritative --apcu-autoloader --with-all-dependencies
	$(call taskDone)

###
# QA
###

.PHONY: linter
linter: ## QA: <composer linter>
	@$(eval filter ?= 'app')
	@composer linter $(filter)
	$(call taskDone)

.PHONY: phpcs
phpcs: ## QA: <composer phpcbs>
	@$(eval filter ?= 'app')
	@composer phpcs $(filter)
	$(call taskDone)

.PHONY: phpcbf
phpcbf: ## QA: <composer phpcbf>
	@$(eval filter ?= 'app')
	@composer phpcbf $(filter)
	$(call taskDone)

.PHONY: phpstan
phpstan: ## QA: <composer phpstan>
	@$(eval filter ?= 'app')
	@composer phpstan $(filter)
	$(call taskDone)

.PHONY: tests
tests: ## QA: <composer tests>
	@$(eval testsuite ?= 'Unit')
	@$(eval filter ?= '.')
	@composer tests --testsuite=$(testsuite) --filter=$(filter)
	$(call taskDone)

.PHONY: tests-unit
tests-unit: ## QA: <composer tests-unit>
	@$(eval filter ?= '.')
	@composer tests-unit --filter=$(filter)
	$(call taskDone)

.PHONY: coverage
coverage: ## QA: <composer coverage>
	@composer coverage
	$(call taskDone)
