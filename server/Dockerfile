FROM ghcr.io/gleam-lang/gleam:v1.16.0-erlang-alpine AS build

WORKDIR /build

COPY gleam.toml manifest.toml ./
RUN gleam deps download

COPY src/ ./src/
COPY priv/ ./priv/

RUN gleam export erlang-shipment

FROM erlang:29-alpine

RUN addgroup -S app && adduser -S app -G app -u 1000

WORKDIR /app

COPY --from=build --chown=app:app /build/build/erlang-shipment /app/

EXPOSE 4000

USER app

CMD ["/app/entrypoint.sh", "run"]
