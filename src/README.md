[![Continuous Integration](https://github.com/AlcidesRC/php-skeleton/actions/workflows/ci.yml/badge.svg)](https://github.com/AlcidesRC/php-skeleton/actions/workflows/ci.yml)

# PHP Skeleton


> An application skeleton for modern PHP projects, PoC, side-projects... 


[TOC]


## Summary

This repository contains an application skeleton following best practices.


### Highlights

- Minimalist project 
- Includes frequently used tools such as a **Linter**, **PHPStan**, **PHPUnit**, **CodeSniffer** and **VarDumper**.


## Requirements

To use this repository you need:

### Software

- [Git](https://git-scm.com/) - The free and open source distributed version control system.

## Built with

This project was built with [Dockerized PHP](https://github.com/alcidesrc/dockerized-php), a lightweight dockerized environment to build PHP applications. 


## Getting Started

Just clone the repository into your preferred path:

```bash
$ mkdir -p ~/path/to/my-new-project && cd ~/path/to/my-new-project
$ git clone git@github.com:alcidesrc/php-skeleton.git .
```

### Conventions

#### Directory structure

```text
.
├── app                 # Your application business logic goes here
├── composer.json       # Application dependencies main file
├── composer.lock       # Application dependencies locked file
├── LICENSE
├── Makefile
├── phpcs.xml           # PHPCS configuration file
├── phpstan.neon        # PHPStan configuration file
├── phpunit.xml         # PHPUnit configuration file
├── public              # Public folder
├── README.md
├── tests               # Tests folder
└── vendor
```

#### Composer commands

Custom commands are added to `composer.json` under the `scripts` section.

##### Available commands

| Command    | Description                                                                  |
| ---------- |------------------------------------------------------------------------------|
| `linter`   | Runs the linter in parallel mode                                             |
| `phpcs`    | Runs **PHP Check Style** command following the PSR-12                        |
| `phpcbf`   | Runs **PHP Code Beautifier** and **Fixer** command following the PSR-12      |
| `phpstan`  | Runs **PHPStan** with the specs defined at `phpstan.neon` configuration file |
| `phpunit`  | Runs **PHPUnit** with the specs defined at `phpunit.xml` configuration file  |
| `tests`    | Runs **PHPUnit** without code coverage support                               |
| `coverage` | Runs **PHPUnit** with **PCOV** code coverage support                         |

#### Makefile

Additionally a *Makefile* is provided with frequently used commands:

```bash
~/path/to/my-new-project$ make

╔════════════════════════════════════════════════════════════════════════════════════════════════╗
║                                                                                                ║
║ 	                                 .: AVAILABLE COMMANDS :.                                ║
║                                                                                                ║
╚════════════════════════════════════════════════════════════════════════════════════════════════╝

· composer-dump                  Composer: executes <composer dump-auto> inside the container
· composer-install               Composer: executes <composer install> inside the container
· composer-remove                Composer: executes <composer remove> inside the container
· composer-require-dev           Composer: executes <composer require --dev> inside the container
· composer-require               Composer: executes <composer require> inside the container
· composer-update                Composer: executes <composer update> inside the container
· check-syntax                   QA: executes <check-syntax> inside the container
· check-style                    QA: executes <check-style> inside the container
· fix-style                      QA: executes <fix-style> inside the container
· phpstan                        QA: executes <composer phpstan> inside the container
· test                           QA: executes <composer paratest> inside the container
· coverage                       QA: executes <composer paracoverage> inside the container

```

##### Installing Dependencies

```bash
$ make composer-install
```

##### Running the Test Cases

```bash
$ make test
```

#### Volumes

##### Coverage report in HTML

Coverage report in HTML is generated on a root folder `/.coverage`

> [!TIP]
>
> If you want the report is generated on a different path, just update accordingly the `composer.json` file under the section `scripts`  


## Security Vulnerabilities

Please review our security policy on how to report security vulnerabilities:

**PLEASE DON'T DISCLOSE SECURITY-RELATED ISSUES PUBLICLY**

### Supported Versions

Only the latest major version receives security fixes.

### Reporting a Vulnerability

If you discover a security vulnerability within this project, please [open an issue here](https://github.com/alcidesrc/php-skeleton/issues). All security vulnerabilities will be promptly addressed.

## License

The MIT License (MIT). Please see [LICENSE](./LICENSE) file for more information.
