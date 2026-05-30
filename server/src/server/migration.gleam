import cigogne
import cigogne/config
import gleam/io
import gleam/result
import server/db
import server/error

pub fn main() {
  let assert Ok(_) = run_all_with_connect()
  io.println("Migrations applied")
}

pub fn run_all() -> Result(Nil, error.MigrationError) {
  use cfg <- error.try(config.get("server"), error.ConfigError)
  use engine <- error.try(cigogne.create_engine(cfg), error.CigogneError)
  cigogne.apply_all(engine) |> result.map_error(error.CigogneError)
}

fn run_all_with_connect() -> Result(Nil, String) {
  use _ <- result.try(db.start_pool())
  use _ <- result.try(
    run_all()
    |> result.map_error(error.message),
  )
  Ok(Nil)
}
