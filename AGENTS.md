# AGENTS.md

A Docker image with the tools to build a PHP project in CI: PHP, Composer, NodeJS, NPM, Yarn, Docker, Buildah and Podman on Alpine Linux, published as `existenz/builder` on Docker Hub. It is the build-time companion of [Docker Webstack](https://github.com/eXistenZNL/Docker-Webstack), which runs the result. The supported versions are the `*.Dockerfile` files in the root and the matrix in `.github/workflows/build-containers.yml`.

## Building and testing

`make` is the wrapper, and CI uses it too. Every target takes `TAG`, the Dockerfile name without `.Dockerfile`:

```bash
make all TAG=8.5   # build, start, test, stop, clean
```

`make start` runs the image as `existenz_builder_instance` with `tests/` mounted. `make test` checks the PHP version, Xdebug and that every tool runs, and runs the PHP scripts in `tests/` for iconv and locales. `run-tests-local.sh` runs every version.

There is no `latest` tag: users pin a PHP version, so it matches the webstack image their project runs on.

## Dockerfile layout

A Dockerfile has two stages. `locales` compiles the preloadable library of GNU libiconv 1.15, which works around the broken iconv in musl through `LD_PRELOAD`, and the musl-locales. The final stage copies both in, installs the tools and the PHP extensions, links `/usr/bin/php`, installs Composer and Yarn, and enables Xdebug.

`cache-tool.sh` ends up as `/usr/local/bin/cache-tool`. Users call it from their `.gitlab-ci.yml`, so its arguments are a public interface: change them only in a backward compatible way.

## Adding a new PHP version

- Copy the newest Dockerfile and rename `phpXX` throughout, including the `/usr/bin/phpXX` symlink, the Xdebug ini path and the comment above `LD_PRELOAD`.
- Add the tag to the CI matrix, to `run-tests-local.sh` and to the table in `README.md`, and move the examples in `README.md` to it.
- Offer the same versions as the webstack.
- A version that is only in Alpine edge becomes an `-edge` tag: a stable Alpine base with only the PHP packages from edge. See `docs/adr/0001-edge-images-use-stable-base.md`.

## Removing a PHP version

A version is removed once no maintained stable Alpine release keeps it up to date, not only at its end of life. See `docs/adr/0002-drop-versions-alpine-stops-updating.md`. The README announces the removal at the top for a while, and the maintainer removes the tag from Docker Hub by hand.
