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
