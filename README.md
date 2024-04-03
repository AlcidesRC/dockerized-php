# Dockerized PHP

> A _dockerized_ container based on PHP-FPM image

[TOC]

## Summary

This repository contains a _dockerized_ environment for building PHP applications based on **php:8.3.4-fpm-alpine** with or without Caddy support.

### Highlights

- **Self-signed local domains** thanks to Caddy.
- Unified environment to build CLI[^1], web applications and/or micro-services based on **PHP8**.
- Allows you to create an optimized **development environment** Docker image
- Allows you to create an optimized **production-ready** Docker image
- A *Makefile* with frequent commands is provided



[^1]: Command Line Interface applications



## Requirements

To use this repository you need:

- [Docker](https://www.docker.com/) - An open source containerization platform.
- [Git](https://git-scm.com/) - The free and open source distributed version control system.



## Built with

| Type              | Component                                                                   | Description                                                              |
| ----------------- |-----------------------------------------------------------------------------|--------------------------------------------------------------------------|
| Infrastructure    | [Docker](https://www.docker.com/)                                           | Containerization platform                                                |
| Service           | [Caddy Server](https://caddyserver.com/)                                    | Open source web server with automatic HTTPS written in Go                |
| Service           | [PHP-FPM](https://www.php.net/manual/en/install.fpm.php)                    | PHP with FastCGI Process Manager                                         |
| Miscelaneous      | [Bash](https://www.gnu.org/software/bash/)                                  | Allows to create an interactive shell within main service                |
| Miscelaneous      | [Make](https://www.gnu.org/software/make/)                                  | Allows to execute commands defined on a _Makefile_                       |



## Getting Started

Just clone the repository into your preferred path:

```bash
$ mkdir -p ~/path/to/my-new-project && cd ~/path/to/my-new-project
$ git clone git@github.com:fonil/dockerized-php.git .
```

### Conventions

#### Dockerfile

`Dockerfile` is based on [multi-stage builds](https://docs.docker.com/build/building/multi-stage/) in order to simplify the process to generate the **development container image** and the **production-ready container image**.

##### Healthcheck

A shell script is provided to allows Docker's deamon to check the container service via `HEALTHCHECK` directive. 



> This health check is defined in the `Dockerfile`



#### Logging

The container service logs to `STDOUT` by default.

#### Directory structure

```text
├── build							# Docker-related configuration files
│   ├── Caddyfile                   # Caddy's configuration file
│   ├── healthcheck.sh              # Shell script for Docker's HEALTHCHECK command
│   └── www.conf                    # PHP-FPM configuration file
├── coverage                        # Code Coverage HTML dashboard
├── src                             # PHP application folder
├── caddy-root-ca-authority.crt     # Generated file with the Caddy Root CA Authority details
├── docker-compose.yml
├── Dockerfile
├── Makefile
└── README.md						# This file
```

#### Development Environment

##### Volumes

There are some volumes created between the *host* and the container service:

| Host path    | Container path | Description                         |
| ------------ | -------------- | ----------------------------------- |
| `./src`      | `/code`        | PHP Application folder              |
| `./coverage` | `/coverage`    | Code Coverage HTML dashboard folder |



> Those volumes can be customized in the `docker-compose.yml` file



##### Available Commands

A *Makefile* is provided with following commands:

```bash
~/path/to/my-new-project$ make

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                           .: AVAILABLE COMMANDS :.                           ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

· build                          Docker: builds the service
· up                             Docker: starts the service
· restart                        Docker: restarts the service
· down                           Docker: stops the service
· logs                           Docker: exposes the service logs
· bash                           Docker: establish a bash session into main container
· install-caddy-certificate      Setup: installs Caddy Local Authority certificate
· show-context                   Setup: show context
```

##### Building the Docker image

To avoid any possible file permissions between the *host* and shared volumes with the container service, a non-root user is created into the container with same credentials than the *host* user. This internally created user is used to run the PHP-FPM service so any internally created file can be shared with the *host* without any file permission issue.

Those details are collected into the `Makefile` and passing each value to `Dockerfile` as a build argument:

| Argument          | How to fill the value | Description                |
| ----------------- | --------------------- | -------------------------- |
| `HOST_USER_NAME`  | `$ id --user --name`  | Current host user name     |
| `HOST_GROUP_NAME` | `$ id --group --name` | Current host group name    |
| `HOST_USER_ID`    | `$ id --user`         | Current host user ID       |
| `HOST_GROUP_ID`   | `$ id --group`        | Current host user group ID |

###### Accessing the container service

```bash
$ docker run -it --rm app:development bash
```

##### Web application

If you are creating a web application and needs a web server to interact with your PHP application, this repository provides an easy way to do it with Caddy, which <u>uses HTTPS by default</u>.

###### Website domain

The default website domain is `https://website.localhost`



> If you want to customize the default website domain please, please update the file `build/Caddyfile` accordingly 



> Additionally please update the _Makefile_  in where you can find a constant containing the current application domain name



###### Certificate Authority (CA) & SSL Certificate

If you experiment any SSL certificate issue on your *host*, please register the **Caddy Authority Certificate** on your browser. 



> A _Makefile_ command is provided called `make install-caddy-certificate` and guides you on this process.



> This is a one-time action due the certificate does not change after rebuilding/restarting the service.



##### PHP Application

PHP application must be placed into `src` folder.



> If you are starting a new PHP application from scratch, please consider start using [PHP Skeleton](https://github.com/fonil/php-skeleton)



##### Testing

###### Mocking Date/Time functions

Testing with date and/or time variations sometimes can be a nightmare. To assist on this topic the **UOPZ** extension has been installed and enabled in the container.



> You should add [slope-it/clock-mock](https://github.com/slope-it/clock-mock) as a development dependency into your `src/composer.json`. This library provides a way for mocking the current timestamp used by PHP for `\DateTime(Immutable)` objects and date/time related functions.



#### Production Environment

##### Building the Docker image

```bash
$ docker buildx build \
--target=build-production \
--build-arg="HOST_USER_ID=82" \
--build-arg="HOST_USER_NAME=www-data" \
--build-arg="HOST_GROUP_ID=82" \
--build-arg="HOST_GROUP_NAME=www-data" \
--tag="app:production" \
.
```



> The default PHP-FPM user is `www-data`  which has `82` as user ID  



##### Accessing the container service

```bash
$ docker run -it --rm app:production sh
```



## Security Vulnerabilities

Please review our security policy on how to report security vulnerabilities:

**PLEASE DON'T DISCLOSE SECURITY-RELATED ISSUES PUBLICLY**

### Supported Versions

Only the latest major version receives security fixes.

### Reporting a Vulnerability

If you discover a security vulnerability within this project, please [open an issue here](https://github.com/fonil/dockerized-php/issues). All security vulnerabilities will be promptly addressed.

## License

The MIT License (MIT). Please see [LICENSE](./LICENSE) file for more information.
