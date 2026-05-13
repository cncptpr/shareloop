# Server

This is the backend for [shareloop](/README.md).

Coming Soon:
If you are not actively developing this, maybe just [starting the backend as
a Docker container](/docs/Docker.md) is enough.

## Requirements

- gleam (in mise.toml)
- not yet: a running [Postgres Database](/docs/Docker.md)

## Getting started

Run `$ mise run server:dev` or `$ gleam run` in `server` (current dir) to start
the server. The server will be available under port 4000.

The server will host an api as described by the OpenAPI spec in `../api/`.
Regenerate `./src/server/api.gleam` by running `mise run server:api:gen`.
