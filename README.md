# Shareloop

Shareloop is a mobile app for lending and borrowing items between individuals.

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
