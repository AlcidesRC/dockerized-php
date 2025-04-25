#!/bin/sh

set -e

export PHP_XDEBUG_MODE="${PHP_XDEBUG_MODE:-debug}"
export PHP_XDEBUG_START_WITH_REQUEST="${PHP_XDEBUG_START_WITH_REQUEST:-yes}"
export PHP_XDEBUG_CLIENT_HOST="${PHP_XDEBUG_CLIENT_HOST:-127.0.0.1}"
export PHP_XDEBUG_CLIENT_PORT="${PHP_XDEBUG_CLIENT_PORT:-9900}"
export PHP_XDEBUG_MAX_NESTING_LEVEL="${PHP_XDEBUG_MAX_NESTING_LEVEL:-3000}"
export PHP_XDEBUG_OUTPUT_DIR="${PHP_XDEBUG_OUTPUT_DIR:-/tmp/xdebug}"
export PHP_XDEBUG_DISCOVER_CLIENT_HOST="${PHP_XDEBUG_DISCOVER_CLIENT_HOST:-false}"
export PHP_XDEBUG_LOG="${PHP_XDEBUG_LOG:-/dev/stdout}"
export PHP_XDEBUG_LOG_LEVEL="${PHP_XDEBUG_LOG_LEVEL:-0}"

envsubst < /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.tmpl > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Executes original command

exec "$@"
