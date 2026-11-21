# Edge images use a stable Alpine base

_Accepted on 2026-11-21_

## Decision Outcome

This repository follows [ADR 0001 of Docker Webstack](https://github.com/eXistenZNL/Docker-Webstack/blob/main/docs/adr/0001-edge-images-use-stable-base.md): an image is always based on a stable Alpine release, `alpine:<major>.<minor>`, and an `-edge` tag takes only its PHP packages from edge.

### Differences for the builder

- The rule also covers the `locales` build stage, which compiles GNU libiconv and musl-locales. Its result is copied into the final image, so it is based on the same stable Alpine release.
- CI rejects any Dockerfile with a `FROM` line that is not `alpine:<major>.<minor>`.
