# Docker Builder

[![Docker Build Status](https://img.shields.io/docker/build/existenz/builder.svg?style=flat-square)](https://hub.docker.com/r/existenz/builder/builds/) [![Docker Pulls](https://img.shields.io/docker/pulls/existenz/builder.svg?style=flat-square)](https://hub.docker.com/r/existenz/builder/) [![license](https://img.shields.io/github/license/existenznl/docker-builder.svg?style=flat-square)](https://github.com/eXistenZNL/Docker-Builder/blob/master/LICENSE)

## About
A container that holds all the tools needed to build a run-of-the-mill modern PHP project in a CI like GitLab-CI.
Optimized for Docker-in-Docker builds that build and push another container to a registry.
Built upon [Alpine Linux](https://alpinelinux.org/), and comes with the latest [PHP](https://secure.php.net/), [Composer](https://getcomposer.org/), [NodeJS](https://nodejs.org/en/), [NPM](https://www.npmjs.com/) and [Yarn](https://yarnpkg.com/lang/en/).

## Why
That's an easy one: speed. Lots of different approaches are taken when setting up a CI pipeline, but not all setups are as fast as they could be. One of the approaches I've seen is where the build is ran inside a pretty clean container, and every tool needed (Composer, NPM, etc.) is pulled in via Docker. And since Docker-in-Docker has no possibility to cache layers, these need to be pulled in over and over again.

Also, setting all these docker pulls up gets kinda messy with a lot of commands needed to perform a complete build. I wanted stuff to be simple, readible, and easy to maintain.

## The goals of this container

- Pull in as few bits from the interwebs as needed, by caching everything that's possible.
- Minimize the lines of code needed in `.gitlab-ci.yml` and optimize readibility.
- Optimally share the built cache between the various stages of a build pipeline.

## So how does it work?

Actually, quite simple. The scenario this container is built for is a [GitLab-CI](https://about.gitlab.com/features/gitlab-ci-cd/) environment that runs in [Docker-in-Docker](https://docs.gitlab.com/ce/ci/docker/using_docker_build.html#use-docker-in-docker-executor) mode. This means the following:
- To build a container without the Docker socket exposed, we must run a Docker instance inside our container using the `docker:dind` container as a service.
- Any container being pulled by the inner docker instance will not be cached since the container will be destroyed afterwards.
- The only container can be cached is the container which is specified in `gitlab-ci.yml` and in which our build is running, because this container is being pulled by the GitLab runner which controls the outside Docker instance.

This container brings the following advantages:
- The image itself is being cached by the GitLab runner, so all tools needed are instantly available.
- Because all the tools you need are embedded, no external tools need to be pulled in over and over again.
- The image has a little helper on board that makes is possible to cache stuff outside of the build directory so more stuff can be cached and re-used between stages in a pipeline.

### Cache all the things!

In order to efficiently make use of the cache between stages, a little helper tool called cache-tool is available in the container.

### Readibility of your CI configuration file

Because we don't need to pull in any extra's we can simply add the commands just as they would normally run:

```yaml

```