# Shareloop

Shareloop is a mobile app for lending and borrowing items between individuals.

## Quickstart - Docker

The easiest way to run this project is with **Docker Compose**.
Run `docker compose up -d` in the project directory. This may take a while.
After it finished access the web-build of the app under `http://localhost:8080`
in your browser.

For more information see the [`./docs/Docker.md`](/docs/Docker.md).

## Quickstart - Development

You need three parts: Database, Server and App.

Recommended is running the Database via **Docker Compose**, the server with [**mise-en-place**](https://mise.jdx.dev/) via `mise run server:dev`. The app can be started via `mise run app:dev`, but using your preferred way of running a flutter app should work.

**mise** will install all relevant dependencies (except **Docker Compose**).

If you want to avoid using mise, refer to the READMEs in app and server and `mise.toml` for information about dependencies, versions and commands.

## Structure

The project is divided into two main parts: [`./app`](/app/README.md) with the
mobile Flutter app, and [`./server`](/server/README.md) a backend for the app.

Both communicate over an API generated from the OpenAPI spec
located in `./api`.

The server also exposes a **WebSocket** endpoint (`/ws`) for realtime chat and
notification updates. See [`docs/WebSocket.md`](docs/WebSocket.md) for details.

The different tools and commands to run the different parts of this project are
documented in `mise.toml`. Either setup [mise-en-place](https://mise.jdx.dev/)
on your machine, or just copy out the commands you need.

For more detailed information, check out the READMEs in app and server.
