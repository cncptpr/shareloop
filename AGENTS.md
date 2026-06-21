# Rules for coding agents

1. Do not edit generated code. Edit its source and re-generate.

2. Fields (DB and API) are either explicitly optional or a real required value. Never abuse empty strings, empty lists, `0`, `-1`, or similar sentinels as defaults to work around a required field.

3. For `OpenCode` agents: Do not ask a question like "Ready to implement?". The user cannot change the mode (e.g. Plan -> Build) when the agent uses the question feature. This results in an unnessesary interaction.

## Generated files (DO NOT EDIT — edit the source listed below and run codegen)

| Generated file(s) | Source | Codegen command |
|---|---|---|
| `server/src/server/sql.gleam` | `server/src/server/sql/*.sql` | `mise run server:sql:gen` (runs squirrel) |
| `server/src/openapi/*.gleam` (except `handlers.gleam`) | `api/shareloop.openapi.yaml` | `mise run server:api:gen` (runs oaspec) |
| `app/gen/api/**/*` | `api/shareloop.openapi.yaml` | `mise run app:api:gen` (runs openapi-generator) |

### Workflow for SQL changes

1. Edit the `.sql` file in `server/src/server/sql/`
2. Run `mise run server:db:migrate` to apply the DB migration
3. Run `mise run server:sql:gen` to regenerate `sql.gleam`
4. Run `gleam check` to verify compilation

### Workflow for API changes

1. Edit `api/shareloop.openapi.yaml`
2. Run `mise run server:api:gen` to regenerate the Gleam API bindings
3. Run `mise run app:api:gen` to regenerate the Flutter API client
4. Run `gleam check` and `flutter analyze` to verify compilation
