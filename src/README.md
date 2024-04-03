# PHP Skeleton

> An application skeleton for modern PHP projects. 

[TOC]

## Summary

This repository contains an application skeleton following best practices.



### Highlights

- Unified environment to build CLI, web applications and/or microservices based on **PHP8**.
- Includes **PCOV**, **PHPCS/PHPCBF**, **PHPUnit**, **UOPZ**, **PHPStan** and a **linter** by default.



## Requirements

To use this repository you need:

### Sofware

- [Git](https://git-scm.com/) - The free and open source distributed version control system.

### Extensions

- [UOPZ](https://www.php.net/manual/en/book.uopz.php) - In order to allow mocking date/time functions
- [PCOV](https://github.com/krakjoe/pcov) - In order to generate the PHP code coverage report



## Built with

| Type              | Component                                                    | Description                                                  |
| ----------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Service           | [PHP-FPM](https://www.php.net/manual/en/install.fpm.php)     | PHP with FastCGI Process Manager                             |
| Miscelaneous      | [Make](https://www.gnu.org/software/make/)                   | Allows to execute commands defined on a _Makefile_           |
| Quality Assurance | [PHP-Parallel-Lint](https://github.com/php-parallel-lint/PHP-Parallel-Lint) | Allows to check the syntax of PHP files in parallel          |
| Quality Assurance | [PHPCS/PHPCBF](https://github.com/PHPCSStandards/PHP_CodeSniffer/) | Allows to check and fix coding style issues                  |
| Quality Assurance | [PHPStan](https://phpstan.org/)                              | Allows to perform static analysis of your application looking for issues |
| Quality Assurance | [PHPUnit](https://phpunit.de/)                               | The PHP Testing Framework                                    |



## Getting Started

Just clone the repository into your preferred path:

```bash
$ mkdir -p ~/path/to/my-new-project && cd ~/path/to/my-new-project
$ git clone git@github.com:fonil/php-skeleton.git .
```

### Conventions

#### Directory structure

```text
.
├── app                 # Application business logic goes here
├── public              # Public folder
│   └── index.php       # Application entry point
├── tests               # Tests folder
│   └── Unit            # Unit Tests folder
├── vendor              # Dependencies folder
├── .gitignore          # Git ignore file
├── composer.json       # Composer dependencies files
├── composer.lock       # Composer lock file
├── LICENSE             # License document
├── Makefile            # Makefile with frequent commands
├── phpstan.neon        # PHPStan configuration file
├── phpunit.xml         # PHPUnit configuration file
└── README.md           # This document
```

#### Custom commands

Custom commands are added to `composer.json` under the `scripts` section.

##### Available commands

| Command          | Description                                                              |
|------------------|--------------------------------------------------------------------------|
| `clear-coverage` | Removes any previous HTML code coverage report                           |
| `tests`          | Runs PHPUnit with the specs defined at `phpunit.xml` configuration file  |
| `coverage`       | Generates the HTML code coverage report                                  |
| `phpcs`          | Runs the PHP Check Style command following the PSR-12                    |
| `phpcbf`         | Runs the PHP Code Beautifier and Fixer command following the PSR-12      |
| `linter`         | Runs the linter in parallel mode                                         |
| `phpstan`        | Runs PHPStan with the specs defined at `phpstan.neon` configuration file |

##### Makefile

Additionally a *Makefile* is provided with frequently used commands:

```bash
~/path/to/my-new-project$ make

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║                           .: AVAILABLE COMMANDS :.                           ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

· composer-dump                  Application: <composer dump-auto>
· composer-install               Application: <composer install>
· composer-remove                Application: <composer remove>
· composer-require-dev           Application: <composer require --dev>
· composer-require               Application: <composer require>
· composer-update                Application: <composer update>
· linter                         QA: <composer linter>
· phpcs                          QA: <composer phpcbs>
· phpcbf                         QA: <composer phpcbf>
· phpstan                        QA: <composer phpstan>
· tests                          QA: <composer tests>
· coverage                       QA: <composer coverage>
· clean-cache                    QA: <composer clean-cache>
```



> This file is really useful when you create a container with a project based on this repository, and you want to run those commands from outside the container. To do so just copy and paste the included steps on your main *Makefile* and adjust the constants accordingly.



#### Volumes

##### Coverage report in HTML

Coverage report in HTML is generated on a root folder `/coverage`



> If you want the report is generated on a different path, just update accordingly the `composer.json` file under the section `scripts`  

 

## Security Vulnerabilities

Please review our security policy on how to report security vulnerabilities:

**PLEASE DON'T DISCLOSE SECURITY-RELATED ISSUES PUBLICLY**

### Supported Versions

Only the latest major version receives security fixes.

### Reporting a Vulnerability

If you discover a security vulnerability within this project, please [open an issue here](https://github.com/fonil/php-skeleton/issues). All security vulnerabilities will be promptly addressed.



## License

The MIT License (MIT). Please see [LICENSE](./LICENSE) file for more information.
