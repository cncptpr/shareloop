import cigogne
import cigogne/config
import gleam/json
import gleam/result
import mist

pub type MigrationError {
  ConfigError(config.ConfigError)
  CigogneError(cigogne.CigogneError)
}

pub fn try(result, error, callback) {
  result.try(result |> result.map_error(error), callback)
}

pub fn try_unwrap(
  result: Result(a, e),
  lazy_or: fn() -> b,
  callback: fn(a) -> b,
) -> b {
  case result {
    Ok(a) -> callback(a)
    Error(_) -> lazy_or()
  }
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

pub type ParseError {
  MistReadError(mist.ReadError)
  NotAStringError(Nil)
  JsonParseError(json.DecodeError)
}
