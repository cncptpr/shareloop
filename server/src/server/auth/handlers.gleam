import generated/middleware
import generated/types
import gleam/bytes_tree
import gleam/http/request
import gleam/http/response
import gleam/json
import gleam/result
import mist
import server/auth
import server/error
import server/parser

pub fn login(req, conn) -> response.Response(mist.ResponseData) {
  case try_login(req, conn) {
    Ok(login_result) -> {
      login_result
      |> types.encode_login_result
      |> respond(status: 200)
    }
    Error(Nil) -> respond_empty(status: 401)
  }
}

fn try_login(req, conn) -> Result(types.LoginResult, Nil) {
  use types.LoginRequest(email:, password:) <- error.try(
    parser.parse_json_body(req, types.login_request_decoder),
    void,
  )
  auth.login(conn, email:, password:) |> result.map_error(void)
}

pub fn logout(req, conn) {
  case try_logout(req, conn) {
    Ok(Nil) -> respond_empty(status: 204)
    Error(Nil) -> respond_empty(status: 401)
  }
}

fn try_logout(req, conn) {
  use token <- error.try(middleware.extract_bearer_auth_token(req), void)
  auth.logout(conn, token) |> result.map_error(void)
}

pub fn refresh(req, conn) {
  case try_refresh(req, conn) {
    Ok(login_result) ->
      login_result |> types.encode_login_result |> respond(status: 200)
    Error(Nil) -> respond_empty(status: 401)
  }
}

fn try_refresh(req, conn) {
  use types.RefreshRequest(refresh_token:) <- error.try(
    parser.parse_json_body(req, types.refresh_request_decoder),
    void,
  )
  auth.refresh_session(conn, refresh_token) |> result.map_error(void)
}

pub fn verify(req, conn) {
  case try_verify(req, conn) {
    Ok(result) -> result |> types.encode_user |> respond(status: 200)
    Error(Nil) -> respond_empty(status: 401)
  }
}

fn try_verify(req, conn) {
  use token <- error.try(middleware.extract_bearer_auth_token(req), void)
  auth.verify_token(conn, token) |> result.map_error(void)
}

fn respond(body, status code) {
  body
  |> json.to_string
  |> bytes_tree.from_string
  |> mist.Bytes
  |> response.set_body(response.new(code), _)
}

fn respond_empty(status code) {
  bytes_tree.new() |> mist.Bytes |> response.set_body(response.new(code), _)
}

fn void(_) {
  Nil
}
