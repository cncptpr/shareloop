# Docker Stack

In the root of this project there is a compose.yaml defining a Docker stack to
host a full web build of this project.

The build is a release build not meant for active development.

It is designed to be started partially so that one can for example only host
the database, or the database and the server, while developing the app.

## Run it

The only requirements to running the stack are **Docker** and **Docker Compose**.

Use `$ docker compose up -d` to start the entire stack. Depending on your
environment you might need to run as admin (e.g. with `$ sudo ...`) and the
docker compose command might be `$ docker-compose`.
Omit the `-d` to stay attached, and get the logs.

Starting it for the first time will also download all the needed *Images* and
build the project. Building takes ~100s on my machine.

To only start individual services, list them like this:
`$ docker compose up server db -d`
