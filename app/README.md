# Mobile App

This is the mobile app for [shareloop](/README.md).

## Requirements

- flutter (in mise.toml)
- a running [server](/server/README.md)
- java (only for codegen)

## Getting Started

Use `$ mise run app:dev`, `$ flutter run` from `app` (the current dir) or you IDE features to start the mobile app.

## API
The API connects by default to _http://127.0.0.1:4000/api_. To configure this, provide a `API_BASE_URL` environment variable, e.g.:
`$ flutter run --dart-define=API_BASE_URL=http://production.example.com/api`

The API code lives in a separate package `./gen/api`, which is generated from an OpenAPI spec in `../api` with `$ mise run app:api:gen`. Code generation requires **Java**.

Usage of the API example: `./lib/state/items.dart`
