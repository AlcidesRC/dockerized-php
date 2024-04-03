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

COMPOSER_FLAGS_ANSI_PROFILE = --ansi --profile
COMPOSER_FLAGS_OPTIMIZE_WITH_ALL_DEPS = --optimize-autoloader --with-all-dependencies

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
	@composer dump-auto $(COMPOSER_FLAGS_ANSI_PROFILE) --no-interaction --optimize --strict-psr
	$(call taskDone)

.PHONY: composer-install
composer-install: ## Application: <composer install>
	@composer install $(COMPOSER_FLAGS_ANSI_PROFILE) --no-interaction --optimize-autoloader --audit
	$(call taskDone)

.PHONY: composer-remove
composer-remove: require-packages ## Application: <composer remove>
	@composer remove $(COMPOSER_FLAGS_ANSI_PROFILE) $(COMPOSER_FLAGS_OPTIMIZE_WITH_ALL_DEPS) --no-interaction --unused $(packages)
	$(call taskDone)

.PHONY: composer-require-dev
composer-require-dev: ## Application: <composer require --dev>
	@composer require $(COMPOSER_FLAGS_ANSI_PROFILE) $(COMPOSER_FLAGS_OPTIMIZE_WITH_ALL_DEPS) --interactive --sort-packages --dev
	$(call taskDone)

.PHONY: composer-require
composer-require: ## Application: <composer require>
	@composer require $(COMPOSER_FLAGS_ANSI_PROFILE) $(COMPOSER_FLAGS_OPTIMIZE_WITH_ALL_DEPS) --interactive --sort-packages
	$(call taskDone)

.PHONY: composer-update
composer-update: ## Application: <composer update>
	@composer update $(COMPOSER_FLAGS_ANSI_PROFILE) $(COMPOSER_FLAGS_OPTIMIZE_WITH_ALL_DEPS) --no-interaction
	$(call taskDone)

###
# QA
###

.PHONY: linter
linter: ## QA: <composer linter>
	@composer linter
	$(call taskDone)

.PHONY: phpcs
phpcs: ## QA: <composer phpcbs>
	@composer phpcs
	$(call taskDone)

.PHONY: phpcbf
phpcbf: ## QA: <composer phpcbf>
	@composer phpcbf
	$(call taskDone)

.PHONY: phpstan
phpstan: ## QA: <composer phpstan>
	@composer phpstan
	$(call taskDone)

.PHONY: tests
tests: ## QA: <composer tests>
	@composer tests
	$(call taskDone)

.PHONY: coverage
coverage: ## QA: <composer coverage>
	@composer coverage
	$(call taskDone)

.PHONY: clean-cache
clean-cache: ## QA: <composer clean-cache>
	@composer clean-cache
	$(call taskDone)
