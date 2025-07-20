[![Continuous Integration](https://github.com/AlcidesRC/dockerized-php/actions/workflows/ci.yml/badge.svg)](https://github.com/AlcidesRC/dockerized-php/actions/workflows/ci.yml)

# Dockerized PHP


> A _dockerized_ environment based on Caddy + PHP-FPM running on separated Linux Alpine containers. 


[TOC]

------



## Summary

This repository contains a _dockerized_ environment for building PHP applications based on **php:8.4.10-fpm-alpine** with Caddy support.

### Highlights

- Unified environment to build <abbr title="Command Line Interface">CLI</abbr>, <u>web applications</u>, and/or <u>micro-services</u> based on **PHP 8**.
- Multi-stage Dockerfile allows you to create optimized **development** or **production-ready** Docker images.
- Uses **Caddy webserver**.
- **Self-signed local domains** thanks to Caddy.
- **Everything on separated Docker services**.


------



## Requirements

To use this repository you need:

- [Docker](https://www.docker.com/) - An open source containerization platform.
- [Git](https://git-scm.com/) - The free and open source distributed version control system.
- [Make](https://www.gnu.org/software/make/) - A command to automate the build/manage process.
- [jq](https://jqlang.github.io/jq/download/) - A lightweight and flexible command-line JSON processor.
- [Gum](https://github.com/charmbracelet/gum) - A tool for glamorous shell scripts.



------



## Built with

| Type           | Component                                                | Description                                               |
| -------------- | -------------------------------------------------------- | --------------------------------------------------------- |
| Infrastructure | [Docker](https://www.docker.com/)                        | Containerization platform                                 |
| Service        | [Caddy Server](https://caddyserver.com/)                 | Open source web server with automatic HTTPS written in Go |
| Service        | [PHP-FPM](https://www.php.net/manual/en/install.fpm.php) | PHP with FastCGI Process Manager                          |
| Miscelaneous   | [Make](https://www.gnu.org/software/make/)               | Allows to execute commands defined on a _Makefile_        |
| Miscelaneous   | [jq](https://jqlang.github.io/jq/download/)              | Allows to beautify the Docker inspections in JSON format  |
| Miscelaneous   | [Gum](https://github.com/charmbracelet/gum)              | Improves the *Makefile* with enhanced CLI widgets         |



------



## Getting Started

Just clone the repository into your preferred path:

```bash
$ mkdir -p ~/path/to/my-new-project && cd ~/path/to/my-new-project
$ git clone git@github.com:AlcidesRC/dockerized-php.git .
```

### Conventions

#### Dockerfile

`Dockerfile` is based on [multi-stage builds](https://docs.docker.com/build/building/multi-stage/) in order to simplify the process to generate the **development container image** and the optimized **production-ready container image**.

##### Defined Stages

| Name                             | Description                                                  |
| -------------------------------- | ------------------------------------------------------------ |
| `base-image`                     | Used to define the base Docker image                         |
| `common`                         | Used to define generic variables: `WORKDIR`, `HEALTCHECK`, etc. |
| `extensions-builder-required`    | Used to build required PHP extensions                        |
| `extensions-builder-development` | Used to build **development** PHP extensions                 |
| `build-development`              | Used to build the development environment                    |
| `optimize-php-dependencies`      | Used to optimize the PHP dependencies in production by removing the development ones |
| `build-production`               | Used to build the **production** environment                 |

###### Defined Stages Hierarchy

```mermaid
---
title: Dockerfile Stages Hierarchy
---
stateDiagram-v2
    [*] --> BaseImage
    BaseImage --> Common
    Common --> ExtensionsBuilderRequired
    
    ExtensionsBuilderRequired --> ExtensionsBuilderDevelopment
    ExtensionsBuilderDevelopment --> BuildDevelopment
    
    ExtensionsBuilderRequired --> OptimizePhpDependencies
    OptimizePhpDependencies --> BuildProduction
```

##### Health check

A custom health check script is provided to check the container service by performing the default `PHP-FPM` `ping/pong` check. 

You can find this shell script at `build/healthcheck.sh`.



> [!NOTE]
>
> Review the `Dockerfile` file and adjust the `HEALTHCHECK` directive options accordingly.



> [!IMPORTANT]
>
> Remember to rebuild the Docker image if you make any change on this file.



##### Non-Privileged User

Current container service uses a **non-privileged user** to execute `PHP-FPM`, with same User/Group ID than the host user.

This mechanism allows to `PHP-FPM` create/update shared resources within the host with the same credentials than current host user, avoiding possible file-permissions issues.

To create this user in the container service, current host user details are collected in the `Makefile` and passed to Docker `build` command as arguments:

| Argument          | Default value   | Required value        | Description                |
| ----------------- | --------------- | --------------------- | -------------------------- |
| `HOST_USER_NAME`  | host-user-name  | `$ id --user --name`  | Current host user name     |
| `HOST_GROUP_NAME` | host-group-name | `$ id --group --name` | Current host group name    |
| `HOST_USER_ID`    | 1000            | `$ id --user`         | Current host user ID       |
| `HOST_GROUP_ID`   | 1000            | `$ id --group`        | Current host user group ID |



> [!NOTE]
>
> Review the `Makefile` and `Dockerfile` files and adjust the arguments to your convenience.



> [!IMPORTANT]
>
> Remember to rebuild the Docker image if you make any change on `Dockerfile` file.



#### Logging

The container service logs to `STDOUT` by default.

#### Project Structure

```text
.
├── docker                                 # Folder with assets required to build the infrastructure
│   ├── caddy                              # Folder with Caddy's configuration file(s)
│   ├── php-fpm                            # Folder with PHP-FPM's configuration file(s)
│   ├── docker-compose.override.dev.yml    # Docker Compose file for development environment
│   ├── docker-compose.override.prod.yml   # Docker Compose file for production environment
│   ├── docker-compose.yml                 # Base Docker Compose file
│   ├── Dockerfile                         # Dockerfile to build the PHP-FPM image
│   ├── entrypoint.sh                      # Entrypoint script which allows to customize the xDebug config file
│   └── healthcheck.sh                     # Healthcheck script
├── README                                 # Folder with README.md required assets
├── src                                    # PHP application folder
├── LICENSE
├── Makefile
├── README-CADDY.md
└── README.md
```

##### Volumes

There is a **bind volume** created between the *host* and the container service:

| Host path | Container path  | Description            |
| --------- | --------------- | ---------------------- |
| `./src`   | `/var/www/html` | PHP application folder |



> [!NOTE]
>
> Review the `docker-compose.dev.yml` files and adjust the volumes to your convenience.



> [!IMPORTANT]
>
> Remember to rebuild the Docker image if you make any change on `Dockerfile` file.




##### Available Commands

A *Makefile* is provided with following commands:

```bash
~/path/to/my-new-project$ make

╔════════════════════════════════════════════════════════════════════════════════╗
║                                                                                ║
║                            .: AVAILABLE COMMANDS :.                            ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
🔹 ENVIRONMENT ... dev                                                          
🔹 DOMAIN URL .... https://localhost                                            
🔹 SERVICE(S) .... caddy app1                                                   
🔹 USER .......... (1000) alcidesramos                                          
🔹 GROUP ......... (1000) alcidesramos                                          

Choose a command...         
> exit                      
  set-environment           
  build                     
  up                        
  down                      
  restart                      
  logs                      
  inspect                   
  shell                     
  composer-dump             
  composer-install          
  composer-update           
  composer-require          
  composer-require-dev      
  check-syntax              
  check-style               
  fix-style                 
  phpstan                   
  test                      
  coverage                  
                            
  ••                        
←↓↑→ navigate • enter submit
```

#### Web Server

This project uses Caddy as main web server which <u>provides HTTPS by default</u>.



> [!WARNING]
>
> Caddy is optional and you can replace/remove it based on your preferences.



##### Default Domain

The default website domain is https://localhost



> [!TIP]
>
> You can customize the domain name in `docker-compose.override.xxx.yml` 
>
> Review as well the `.env` to ensure `WEBSITE_URL` constant has the desired domain name for development environment.



> [!IMPORTANT]
>
> Remember to restart the container service(s) if you make any change on any Docker file.



##### Certificate Authority (CA) & SSL Certificate

You can generate/register the **Caddy Authority Certificate** in order to get `SSL` support .



> [!NOTE]
>
> Just execute `make install-caddy-certificate` and follow the provided guidelines to generate the Caddy Authority Certificate and install it on your host.



> [!IMPORTANT]
>
> Remember to reinstall the certificate if you rebuild the container service.




#### PHP Application

PHP application must be placed into `src` folder.



> [!TIP]
>
> There are some `Makefile` commands that allows you to install a [PHP Skeleton](https://github.com/alcidesrc/php-skeleton) as boilerplate, [Laravel](https://github.com/laravel/laravel) or [Symfony](https://symfony.com/) when creating `PHP` applications from scratch.



### Development

#### Set the environment

This command allows to specify the environment to be working on.

```bash
$ make set-environment
```

```bash
╔════════════════════════════════════════════════════════════════════════════════╗
║                                                                                ║
║                            .: AVAILABLE COMMANDS :.                            ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
🔹 ENVIRONMENT ... dev                                                         
🔹 DOMAIN URL .... https://localhost                                            
🔹 SERVICE(S) .... caddy app1                                                   
🔹 USER .......... (1000) alcidesramos                                          
🔹 GROUP ......... (1000) alcidesramos                                          

Setting up Makefile environment...
> dev                             
  prod     
```

> [!TIP]
>
> This value is persisted on `.env` file to improve the UX.

#### Building the container

```bash
$ make build
```

#### Starting the container service

```bash
$ make up
```

#### Extracting Caddy Local Authority - 20XX ECC Root 

```bash
$ make install-caddy-certificate
```

#### Accessing to web application

```bash
$ make open-website
```

#### Service logs

```bash
$ make logs
```

#### Inspecting services

```bash
$ make inspect
```

#### Stopping the container service

```bash
$ make down
```

### Production

#### Setup the environment

This command allows to specify the environment to be working on.

```bash
$ make set-environment
```

```bash
╔════════════════════════════════════════════════════════════════════════════════╗
║                                                                                ║
║                            .: AVAILABLE COMMANDS :.                            ║
║                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════╝
🔹 ENVIRONMENT ... dev                                                         
🔹 DOMAIN URL .... https://localhost                                            
🔹 SERVICE(S) .... caddy app1                                                   
🔹 USER .......... (1000) alcidesramos                                          
🔹 GROUP ......... (1000) alcidesramos                                          

Setting up Makefile environment...
  dev                             
> prod     
```

> [!TIP]
>
> This value is persisted on `.env` file to improve the UX.

#### Building the container

```bash
$ make build
```

#### Starting the container service

```bash
$ make up
```

#### Extracting Caddy Local Authority - 20XX ECC Root 

```bash
$ make install-caddy-certificate
```

#### Accessing to web application

```bash
$ make open-website
```

#### Service logs

```bash
$ make logs
```

#### Inspecting services

```bash
$ make inspect
```

#### Stopping the container service

```bash
$ make down
```



### Debug / Setup PHPStorm

#### Docker-Compose Environment

Please update the `docker-compose.override.dev.yml` file with proper `PHP_XDEBUG_CLIENT_HOST` IP address. You can get this value just by executing the following command:

```bash
$ make get-xdebug-client-host
```

So the `docker-compose.override.dev.yml` should look like:

```yaml
environment:
    - PHP_XDEBUG_IDEKEY=PHPSTORM
    - PHP_XDEBUG_MODE=develop,coverage,debug,profile
    - PHP_XDEBUG_START_WITH_REQUEST=yes
    - PHP_XDEBUG_CLIENT_HOST=172.18.0.1
    - PHP_XDEBUG_CLIENT_PORT=9003
    - PHP_XDEBUG_MAX_NESTING_LEVEL=3000
    - PHP_XDEBUG_OUTPUT_DIR=/tmp/xdebug
    - PHP_XDEBUG_DISCOVER_CLIENT_HOST=false
    - PHP_XDEBUG_LOG=/dev/stdout
    - PHP_XDEBUG_LOG_LEVEL=0
...
```

#### Help > Change Memory Settings

To allow PHPStorm index huge projects consider to increase the default assigned memory amount from 2048 MiB up to 8192 MiB. 

![phpstorm-memory-settings](README/setup-phpstorm-memory/phpstorm-memory-settings.png)

#### Settings > PHP > Debug

Ensure the `Max. simultaneous connections` is set to 1 to avoid trace collisions when debugging.

![phpstorm-debug](README/setup-phpstorm-xdebug/phpstorm-settings-php-debug.png)

#### Settings > PHP > Servers

Ensure the `~/path/to/my-new-project/src` folder is mapped to `/var/www/html`

![phpstorm-settings-php-servers](README/setup-phpstorm-xdebug/phpstorm-settings-php-servers.png)

#### Settings > PHP

![phpstorm-settings-php-settings](README/setup-phpstorm-xdebug/phpstorm-settings-php-settings.png)

![phpstorm-settings-php-settings-cli-interpreter](README/setup-phpstorm-xdebug/phpstorm-settings-php-settings-cli-interpreter.png)



> [!IMPORTANT]
>
> When selecting Docker Compose configuration files, ensure to include:
>
> 1. The `docker-compose.yml` file, which contains the default service(s) specification
> 2. The `docker-compose.override.dev.yml` file, which may contains some override values or customization from default specification.
>
> **The order on here is important!**



![phpstorm-settings-php-settings-cli-interpreter-configuration-files](README/setup-phpstorm-xdebug/phpstorm-settings-php-settings-cli-interpreter-configuration-files.png)



------




## Security Vulnerabilities

Please review our security policy on how to report security vulnerabilities:

**PLEASE DON'T DISCLOSE SECURITY-RELATED ISSUES PUBLICLY**

### Supported Versions

Only the latest major version receives security fixes.

### Reporting a Vulnerability

If you discover a security vulnerability within this project, please [open an issue here](https://github.com/alcidesrc/dockerized-php/issues). All security vulnerabilities will be promptly addressed.



------



## License

The MIT License (MIT). Please see [LICENSE](./LICENSE) file for more information.
