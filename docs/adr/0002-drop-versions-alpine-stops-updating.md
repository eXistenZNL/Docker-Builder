# Drop PHP versions that are no longer first class

_Accepted on 2026-11-21_

## Decision Outcome

This repository follows [ADR 0002 of Docker Webstack](https://github.com/eXistenZNL/Docker-Webstack/blob/main/docs/adr/0002-drop-versions-alpine-stops-updating.md): a PHP version is built as long as a maintained stable Alpine release carries it and keeps its packages up to date. Once that stops, the image stops building and its tag is removed from Docker Hub, even before the version's end of life.

### Differences for the builder

- The builder runs PHP on the command line in CI, not as PHP-FPM behind a web server, so a flaw that needs a web request reaches it less easily. The rule applies anyway: a project builds on `existenz/builder:8.x` and runs on `existenz/webstack:8.x`, so both images offer the same PHP versions, and scanners that rely on the Alpine secdb stay silent about the builder just as they do about the webstack.
- NodeJS comes from the same Alpine release as PHP and has no policy of its own. When an image moves to a newer Alpine release, NodeJS moves with it, as it did from 22 to 24 for 8.3 and 8.4 in October 2026. A project that needs a fixed NodeJS version pins it itself.
