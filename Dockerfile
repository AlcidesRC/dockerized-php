# syntax=docker/dockerfile:1

# STAGE: BASE-IMAGE

FROM php:8.3-fpm-alpine AS base-image


# STAGE: COMMON

FROM base-image AS common

WORKDIR /code

# Add OS dependencies
RUN apk update && apk add --no-cache \
    	fcgi

# Add a custom HEALTHCHECK script
# Ensure the `healthcheck.sh` can be executed inside the container
COPY --chmod=777 build/healthcheck.sh /healthcheck.sh
HEALTHCHECK --interval=10s --timeout=1s --retries=3 CMD /healthcheck.sh


# STAGE: EXTENSIONS-BUILDER

FROM base-image AS extensions-builder

# Add, compile and configure PHP extensions
RUN curl -sSL https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions -o - | sh -s \
        pcov \
        uopz \
        xdebug


# STAGE: BUILD-DEVELOPMENT

FROM common AS build-development

ARG HOST_USER_ID=1001
ARG HOST_USER_NAME=host-user-name
ARG HOST_GROUP_ID=1001
ARG HOST_GROUP_NAME=host-group-name

ENV ENV=DEVELOPMENT

# Add __ONLY__ compiled extensions & their config files 
COPY --from=extensions-builder /usr/local/lib/php/extensions/*/* /usr/local/lib/php/extensions/no-debug-non-zts-20230831/
COPY --from=extensions-builder /usr/local/etc/php/conf.d/* /usr/local/etc/php/conf.d/

# Add Composer from public Docker image
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Add OS dependencies related with development
RUN apk update && apk add --no-cache \
        bash \
        make \
        ncurses \
        util-linux

# Add custom user to www-data group
RUN addgroup --gid ${HOST_GROUP_ID} ${HOST_GROUP_NAME} \
    && adduser --shell /bin/bash --uid ${HOST_USER_ID} --ingroup ${HOST_GROUP_NAME} --ingroup www-data --disabled-password --gecos '' ${HOST_USER_NAME}

# Setup PHP-FPM
COPY build/www.conf /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -r "s/USER-NAME/${HOST_USER_NAME}/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i -r "s/GROUP-NAME/${HOST_GROUP_NAME}/g" /usr/local/etc/php-fpm.d/www.conf

# Setup xDebug
COPY build/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN touch /var/log/xdebug.log \
    && chmod 0777 /var/log/xdebug.log


# STAGE: OPTIMIZE-PHP-DEPENDENCIES

FROM composer as optimize-php-dependencies

# First copy Composer files
COPY ./src/composer.json ./src/composer.lock /app/

# Docker will cache this step and reuse it if no any change has being done on previuos step
RUN composer install \
    --ignore-platform-reqs \
    --no-ansi \
    --no-autoloader \
    --no-interaction \
    --no-scripts \
    --prefer-dist \
    --no-dev

# Ensure to copy __ONLY__ the PHP application folder(s) without the `./src/vendor` folder
COPY src/app /app/app
COPY src/public /app/public

# Recompile application cache
RUN composer dump-autoload \
	--optimize \
	--classmap-authoritative


# STAGE: BUILD-PRODUCTION

FROM common AS build-production

ENV ENV=PRODUCTION

# Add the optimized for production application
COPY --from=optimize-php-dependencies --chown=www-data:www-data /app /code

# Setup PHP-FPM
COPY build/www.conf /usr/local/etc/php-fpm.d/www.conf
RUN sed -i -r "s/USER-NAME/www-data/g" /usr/local/etc/php-fpm.d/www.conf \
    && sed -i -r "s/GROUP-NAME/www-data/g" /usr/local/etc/php-fpm.d/www.conf

