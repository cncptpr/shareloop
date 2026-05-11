This is the backend for [shareloop](/README.md).

Coming Soon:
If you are not activly developing this, maybe just starting the backend as a docker container is enough: [[/docs/Docker.md]]

# Requirements

- gleam (in mise.toml)
- not jet: a running [Postgress Database](/docs/Docker.md#postgress)

# Getting started

Run `$ mise run server:dev` or `$ gleam run` in `server` (current dir) to start the server.
The server will be avaiable under port 4000.

The server will host an api as described by the OpenAPI spec in `../api/`. Regenerate `./src/server/api.gleam` by running `mise run server:api:gen`.
