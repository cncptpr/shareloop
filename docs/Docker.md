# Docker Stack

In the root of this project there is a compose.yaml defining a Docker stack to
host a full web build of this project.

It’s a release build (not intended for active development), but it supports
partial startup, so you can run only the database, or the database plus the
server, while developing the app.

## Run it

The only requirements are **Docker** and **Docker Compose**.

Use `$ docker compose up -d` to start the entire stack. Depending on your
environment you might need to run as admin (e.g. with `$ sudo ...`) and the
docker compose command might be `$ docker-compose`.
Omit the `-d` to stay attached, and get the logs.

Starting it for the first time will also download all the needed *Images* and
build the project. Building takes ~100s on my machine.

To only start individual services, list them like this:
`$ docker compose up -d server db`

## Rebuild

If a change to the source code was made, docker will NOT automatically rebuild.
Run `$ docker compose down` to stop whatever is running,
and use `$ docker compose up --build` to force a rebuild.
The `up --build` command still support starting only individual services.
