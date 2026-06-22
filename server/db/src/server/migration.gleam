import cigogne
import cigogne/config
import gleam/io
import gleam/result

pub type MigrationError {
  ConfigError(config.ConfigError)
  CigogneError(cigogne.CigogneError)
}

fn try_(result, error, callback) {
  result.try(result |> result.map_error(error), callback)
}

pub fn message(e: MigrationError) -> String {
  case e {
    ConfigError(e) -> config.get_error_message(e)
    CigogneError(inner) -> {
      cigogne.print_error(inner)
      "Cigogne error (see stderr)"
    }
  }
}

pub fn main() {
  let assert Ok(_) = run_all()
  io.println("Migrations applied")
}

pub fn run_all() -> Result(Nil, MigrationError) {
  use cfg <- try_(config.get("db"), ConfigError)
  use engine <- try_(cigogne.create_engine(cfg), CigogneError)
  cigogne.apply_all(engine) |> result.map_error(CigogneError)
}
