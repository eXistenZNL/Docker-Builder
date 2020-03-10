# Docker Builder

[![Docker Build Status](https://img.shields.io/travis/eXistenZNL/Docker-Builder.svg?style=flat-square)](https://travis-ci.org/eXistenZNL/Docker-Builder) [![Docker Pulls](https://img.shields.io/docker/pulls/existenz/builder.svg?style=flat-square)](https://hub.docker.com/r/existenz/builder/) [![License](https://img.shields.io/github/license/existenznl/docker-builder.svg?style=flat-square)](https://github.com/eXistenZNL/Docker-Builder/blob/master/LICENSE)

## About
A container that holds all the tools needed to build a run-of-the-mill modern PHP project in a CI like GitLab-CI.
Optimized for Docker-in-Docker builds that build and push another container to a registry.
Built upon [Alpine Linux](https://alpinelinux.org/), and comes with the latest [PHP](https://secure.php.net/),
[Composer](https://getcomposer.org/), [NodeJS](https://nodejs.org/en/), [NPM](https://www.npmjs.com/) and
[Yarn](https://yarnpkg.com/lang/en/).

## Why
That's an easy one: speed. Lots of different approaches are taken when setting up a CI pipeline, but not all setups are
as fast as they could be. One of the approaches I've seen is where the build is ran inside a pretty clean container, and
every tool needed (Composer, NPM, etc.) is pulled in via Docker. And since Docker-in-Docker has no possibility to cache
layers, these need to be pulled in over and over again.

Also, setting all these docker pulls up gets kinda messy with a lot of commands needed to perform a complete build. I
wanted stuff to be simple, readible, and easy to maintain.

## The goals of this container

- Pull in as few bits from the interwebs as needed, by caching everything that's possible.
- Minimize the lines of code needed in `.gitlab-ci.yml` and optimize readibility.
- Optimally share the built cache between the various stages of a build pipeline.

## So how does it work?

Actually, quite simple. The scenario this container is built for is a
[GitLab-CI](https://about.gitlab.com/features/gitlab-ci-cd/) environment that runs in
[Docker-in-Docker](https://docs.gitlab.com/ce/ci/docker/using_docker_build.html#use-docker-in-docker-executor) mode.
This means the following:
- To build a container without the Docker socket exposed, we must run a Docker instance inside our container using the
`docker:dind` container as a service.
- Any container being pulled by the inner docker instance will not be cached since the container will be destroyed
afterwards.
- The only container can be cached is the container which is specified in `gitlab-ci.yml` and in which our build is
running, because this container is being pulled by the GitLab runner which controls the outside Docker instance.

This container brings the following advantages:
- The image itself is being cached by the GitLab runner, so all tools needed are instantly available.
- Because all the tools you need are embedded, no external tools need to be pulled in over and over again.
- The image has a little helper on board that makes is possible to cache stuff outside of the build directory so more
stuff can be cached and re-used between stages in a pipeline.

## Cache all the things!

In order to efficiently make use of the cache between stages, a little helper tool called cache-tool is available in the
container. This tool makes it possible to cache directories outside of the build dir, something that is normally not
allowed by the GitLab-CI runner.

This enables us to make use of the native cache of various tools, e.g. Composer or Yarn. Doing
so allows us to install and remove dependencies at will between stages by using the local cache, without grabbing stuff
from the internet.

To make this work, the cache must be configured on a global level in your `.gitlab-ci.yml`, so all stages use the same
cache directories throughout the build. Also add the directory .cache:

```yaml
cache:
  untracked: false
  paths:
    - .cache/
    - vendor/
    - node_modules/
```

The added benefit of this is that it makes your `.gitlab-ci.yml` more readible.

We also need to call the cache-tool before and after running a stage.
For example, to cache Composers cache directory, add the following to your `.gitlab-ci.yml`:

```yaml
some stage:
  before_script:
    - cache-tool extract composer:~/.composer
  after_script:
    - cache-tool collect composer:~/.composer
```
The cache-tool allows to cache more than one directory, by simply adding more parameters to the command:
```bash
$ cache-tool collect name1:/some/dir name2:~/dir-from-homedir
```

The things you list for collection or extraction are up to you, and consist of a key and a directory to cache. The key
will be used for the directory name inside the .cache

Just make sure the same directories are listed for extraction and collection.

Some directories that you probably want to cache if you use the tools:

| Tool     | Cache directory              |
| ---------|------------------------------|
| Composer | ~/.composer                  |
| NPM      | ~/.npm                       |
| Yarn     | /usr/local/share/.cache/yarn |

## An example that shows the improved readability

Because we don't need to pull in any extra's we don't have to clutter our build script with curl commands, prefetchers,
or other exotic script. We can instead simply add the commands just as they would normally run, this makes our
configuration really readable and short. A simple example containing two stages is shown here:

```yaml
stages:
  - testCode
  - buildContainer

cache:
  untracked: false
  paths:
    - .cache/
    - vendor/

test:
  image: existenz/builder:latest
  stage: testCode
  before_script:
    - cache-tool extract yarn:/usr/local/share/.cache/yarn composer:~/.composer
  script:
    - composer install --ignore-platform-reqs
    - vendor/bin/phpcs --standard=PSR2 app/
  after_script:
    - cache-tool collect yarn:/usr/local/share/.cache/yarn composer:~/.composer

build container:
  image: existenz/builder:latest
  stage: buildContainer
  before_script:
    - cache-tool extract yarn:/usr/local/share/.cache/yarn composer:~/.composer
  script:
    - composer install --ignore-platform-reqs --no-dev
    - yarn install
    - yarn run production
    - docker build
  after_script:
    - cache-tool collect yarn:/usr/local/share/.cache/yarn composer:~/.composer
```

## Automated builds

The containers are automatically rebuilt and tested every week to make sure they are up to date.

## Version matrix

This container is available in different versions, see below what's in each version:

Click any version to see what specific version is currently available, but keep in mind that this might differ slightly from the moment these containers were built.

Also keep in mind that the Codecasts repo, whilst providing the latest versions of PHP, might not have all PHP extensions you need.

| Container version      | PHP                                                                     | NodeJS                                                              | Yarn                                          | Composer                                  |
| -----------------------|-------------------------------------------------------------------------|---------------------------------------------------------------------|-----------------------------------------------|-------------------------------------------|
| 5.6                    | [5.6](https://pkgs.alpinelinux.org/package/v3.5/main/x86_64/php5)       | [6](https://pkgs.alpinelinux.org/package/v3.5/main/x86_64/nodejs)   | [Latest stable](https://yarnpkg.com/lang/en/) | [Latest stable](https://getcomposer.org/) |
| 7.0                    | [7.0](https://pkgs.alpinelinux.org/package/v3.5/community/x86_64/php7)  | [6](https://pkgs.alpinelinux.org/package/v3.5/main/x86_64/nodejs)   | [Latest stable](https://yarnpkg.com/lang/en/) | [Latest stable](https://getcomposer.org/) |
| 7.1                    | [7.1](https://pkgs.alpinelinux.org/package/v3.6/community/x86_64/php7)  | [6](https://pkgs.alpinelinux.org/package/v3.6/main/x86_64/nodejs)   | [Latest stable](https://yarnpkg.com/lang/en/) | [Latest stable](https://getcomposer.org/) |
| 7.2                    | [7.2](https://pkgs.alpinelinux.org/package/v3.8/community/x86_64/php7)  | [8](https://pkgs.alpinelinux.org/package/v3.8/main/x86_64/nodejs)   | [Latest stable](https://yarnpkg.com/lang/en/) | [Latest stable](https://getcomposer.org/) |
| 7.3 (latest)           | [7.3](https://pkgs.alpinelinux.org/package/v3.10/community/x86_64/php7) | [10](https://pkgs.alpinelinux.org/package/v3.10/main/x86_64/nodejs) | [Latest stable](https://yarnpkg.com/lang/en/) | [Latest stable](https://getcomposer.org/) |
| 7.4-codecasts (latest) | [7.4](https://dl.bintray.com/php-alpine/v3.10/php-7.4/x86_64/)          | [10](https://pkgs.alpinelinux.org/package/v3.10/main/x86_64/nodejs) | [Latest stable](https://yarnpkg.com/lang/en/) | [Latest stable](https://getcomposer.org/) |

## Bugs, questions, and improvements

If you found a bug or have a question, please open an issue on the GitHub Issue tracker.
Improvements can be sent by a Pull Request against the master branch and are greatly appreciated!