import cigogne
import cigogne/config
import gleam/result

pub type MigrationError {
  ConfigError(config.ConfigError)
  CigogneError(cigogne.CigogneError)
}

pub fn try(result, error, callback) {
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
