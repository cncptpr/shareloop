import envoy
import gleam/erlang/process
import gleam/otp/actor
import gleam/result
import pog

const db_url_default = "postgres://shareloop:shareloop@localhost:5432/shareloop"

const db_url_var_name = "DATABASE_URL"

pub fn start_pool() -> Result(pog.Connection, String) {
  let url =
    envoy.get(db_url_var_name)
    |> result.lazy_unwrap(fn() {
      envoy.set(db_url_var_name, db_url_default)
      db_url_default
    })

  // TODO: Replace error string with error union
  use config <- result.try(
    pog.url_config(process.new_name("shareloop_db"), url)
    |> result.map_error(fn(_) { "Invalid DATABASE_URL" }),
  )

  use started <- result.try(
    pog.start(config)
    |> result.map_error(fn(_) { "Failed to start database pool" }),
  )

  let actor.Started(data: conn, ..) = started
  Ok(conn)
}
