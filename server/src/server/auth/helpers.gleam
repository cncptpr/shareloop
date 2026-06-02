import generated/middleware
import generated/types
import gleam/http/request
import gleam/result
import pog
import server/auth

pub fn verify_request(
  req: request.Request(a),
  conn: pog.Connection,
) -> Result(types.User, Nil) {
  case middleware.extract_bearer_auth_token(req) {
    Error(_) -> Error(Nil)
    Ok(token) ->
      auth.verify_token(conn, token) |> result.map_error(fn(_) { Nil })
  }
}
