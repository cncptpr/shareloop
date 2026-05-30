import gleam/bit_array
import gleam/json
import gleam/result
import mist
import server/consts.{max_body_limit}
import server/error

pub fn parse_json_body(req, decoder) {
  use req <- error.try(
    mist.read_body(req, max_body_limit:),
    error.MistReadError,
  )

  use str <- error.try(bit_array.to_string(req.body), error.NotAStringError)

  str |> json.parse(decoder()) |> result.map_error(error.JsonParseError)
}
