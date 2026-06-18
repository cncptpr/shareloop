import generated/handlers
import generated/router
import gleam/bit_array
import gleam/bytes_tree
import gleam/dict
import gleam/erlang/process
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import mist
import server/auth
import server/consts
import server/db
import server/migration
import server/sql
import simplifile
import youid/uuid

pub fn main() {
  let assert Ok(conn) = db.start_pool()
  io.println("Database pool started")

  let assert Ok(_) = migration.run_all()
  io.println("Migrations applied")

  let assert Ok(_) = simplifile.create_directory_all("uploads")
  io.println("Uploads directory ensured")

  let assert Ok(_) =
    handler(_, conn)
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(4000)
    |> mist.start

  process.sleep_forever()
}

fn handler(
  req: request.Request(mist.Connection),
  conn,
) -> response.Response(mist.ResponseData) {
  let method = req.method |> http.method_to_string
  let segments = request.path_segments(req)

  io.println("[Info] " <> method <> " " <> req.path)

  case segments {
    ["api", "images", image_id] if method == "GET" ->
      handle_image_get(conn, image_id)
    ["api", ..rest] -> route_via_oaspec(method, rest, req, conn)
    _ -> respond_not_found()
  }
}

fn handle_image_get(
  conn,
  raw_image_id: String,
) -> response.Response(mist.ResponseData) {
  case uuid.from_string(raw_image_id) {
    Error(_) -> respond_error(400)
    Ok(image_uuid) -> {
      case sql.get_item_image(conn, image_uuid) {
        Error(_) -> respond_error(500)
        Ok(result) -> {
          case list.first(result.rows) {
            Error(_) -> respond_error(404)
            Ok(row) -> {
              let ext = mime_to_ext(row.mime_type)
              let filepath = "uploads/" <> raw_image_id <> "." <> ext

              case mist.send_file(filepath, offset: 0, limit: None) {
                Error(_) -> respond_error(500)
                Ok(body) ->
                  response.new(200)
                  |> response.prepend_header("content-type", row.mime_type)
                  |> response.set_body(body)
              }
            }
          }
        }
      }
    }
  }
}

fn mime_to_ext(mime: String) -> String {
  case mime {
    "image/png" -> "png"
    "image/gif" -> "gif"
    "image/webp" -> "webp"
    _ -> "jpg"
  }
}

fn route_via_oaspec(
  method: String,
  segments: List(String),
  req: request.Request(mist.Connection),
  conn,
) -> response.Response(mist.ResponseData) {
  let bearer_token = extract_bearer_token(req.headers)

  let body_str = case mist.read_body(req, consts.max_upload_limit()) {
    Error(_) -> ""
    Ok(r) -> bit_array.to_string(r.body) |> result.unwrap("")
  }

  let headers_dict = dict.from_list(req.headers)
  let protected = route_is_protected(method, segments)

  case protected {
    True -> {
      case bearer_token {
        None -> respond_error(401)
        Some(token) -> {
          case auth.verify_token(conn, token) {
            Error(_) -> respond_error(401)
            Ok(_) -> {
              let app_state = handlers.State(conn: conn, bearer_token: Some(token))
              let serv_resp = router.route(
                app_state,
                method,
                segments,
                dict.from_list([]),
                headers_dict,
                body_str,
              )
              to_mist_response(serv_resp)
            }
          }
        }
      }
    }
    False -> {
      let app_state = handlers.State(conn: conn, bearer_token: bearer_token)
      let serv_resp = router.route(
        app_state,
        method,
        segments,
        dict.from_list([]),
        headers_dict,
        body_str,
      )
      to_mist_response(serv_resp)
    }
  }
}

fn route_is_protected(method: String, segments: List(String)) -> Bool {
  case method, segments {
    "POST", ["items"] -> True
    "PUT", ["items", _] -> True
    "POST", ["items", _, "images"] -> True
    "PUT", ["items", _, "images"] -> True
    "POST", ["items", _, "rent-requests"] -> True
    "GET", ["rent-requests"] -> True
    "GET", ["rent-requests", _] -> True
    "POST", ["rent-requests", _, "messages"] -> True
    "GET", ["rent-requests", _, "messages"] -> True
    "POST", ["rent-requests", _, "offers"] -> True
    "GET", ["rent-requests", _, "offers"] -> True
    "POST", ["offers", _, "accept"] -> True
    "POST", ["rent-requests", _, "confirm-borrow"] -> True
    "POST", ["rent-requests", _, "confirm-return"] -> True
    _, _ -> False
  }
}

fn extract_bearer_token(
  headers: List(#(String, String)),
) -> Option(String) {
  let auth_value = do_find_auth_header(headers)

  case auth_value {
    None -> None
    Some(value) -> {
      let parts = string.split(value, " ")
      case parts {
        ["Bearer", token, ..] -> Some(token)
        _ -> None
      }
    }
  }
}

fn do_find_auth_header(
  headers: List(#(String, String)),
) -> Option(String) {
  case headers {
    [] -> None
    [first, ..rest] -> {
      let key = first.0
      let value = first.1
      case string.lowercase(key) {
        "authorization" -> Some(value)
        _ -> do_find_auth_header(rest)
      }
    }
  }
}

fn to_mist_response(
  serv_resp: router.ServerResponse,
) -> response.Response(mist.ResponseData) {
  let resp = response.new(serv_resp.status)

  let resp = list.fold(serv_resp.headers, resp, fn(r, header) {
    response.prepend_header(r, header.0, header.1)
  })

  case serv_resp.body {
    router.TextBody(text) ->
      response.set_body(resp, mist.Bytes(bytes_tree.from_string(text)))
    router.BytesBody(bits) ->
      response.set_body(resp, mist.Bytes(bytes_tree.from_bit_array(bits)))
    router.EmptyBody -> response.set_body(resp, mist.Bytes(bytes_tree.new()))
  }
}

fn respond_not_found() -> response.Response(mist.ResponseData) {
  response.new(404) |> response.set_body(mist.Bytes(bytes_tree.new()))
}

fn respond_error(status: Int) -> response.Response(mist.ResponseData) {
  response.new(status) |> response.set_body(mist.Bytes(bytes_tree.new()))
}
