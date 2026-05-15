# Server

This is the backend for [shareloop](/README.md).

If you are not actively developing this, [starting the server as
a Docker container](/docs/Docker.md) should be enough.

## Requirements

- gleam (in mise.toml)
- a running [Postgres Database](/docs/Docker.md)

## Getting started

Run `$ mise run server:dev` or `$ gleam run` in `server` (current dir) to start
the server. The server will be available under port 4000.

The server will host an api as described by the OpenAPI spec in `../api/`.
Regenerate the types and helpers from the spec by running
`$ mise run server:api:gen`.

## Database

For querying the database `squirrel` is used. Write raw sql statments, and
let `squirrel` turn them into typed and safe function that can just be called.

Write a SQL statment into `src/server/sql/<name>.sql` file, and run
`$ mise run server:sql:gen`. A function `<name>` should now be avaiable in the
server/sql module.

The schema is defined as migrations in `priv/migrations/<time>-<name>.sql`.
Follow the patter of the exisiting migrations. Migrations will be applied
when re-generating the SQL code, running *Seeding*, starting the server or
with `$ mise run server:db:migrate`.

To populate the Database with example data run `$ mise run server:db:seed`.
Remember to add new example data when expanding the schema.
