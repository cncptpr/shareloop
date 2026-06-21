FROM ghcr.io/gleam-lang/gleam:v1.16.0-erlang-alpine AS build

WORKDIR /build

COPY gleam.toml manifest.toml ./
COPY db/gleam.toml ./db/
RUN gleam deps download

COPY src/ ./src/
COPY db/src/ ./db/src/
COPY db/priv/ ./db/priv/

RUN gleam export erlang-shipment

FROM erlang:29-alpine

RUN addgroup -S app && adduser -S app -G app -u 1000

WORKDIR /app

COPY --from=build --chown=app:app /build/build/erlang-shipment /app/

ENV UPLOADS_DIR=/uploads

RUN mkdir -p /uploads && chown app:app /uploads

EXPOSE 4000

USER app

CMD ["/app/entrypoint.sh", "run"]
