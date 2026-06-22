import gleam/bit_array
import gleam/bytes_tree
import gleam/dict
import gleam/dynamic/decode
import gleam/erlang/process
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import mist
import openapi/handlers
import openapi/router
import server/auth
import server/config
import server/db
import server/migration
import server/notifications
import server/sql
import simplifile
import youid/uuid

pub fn main() {
  let assert Ok(conn) = db.start_pool()
  io.println("Database pool started")

  let assert Ok(_) = migration.run_all()
  io.println("Migrations applied")

  io.println("Creating " <> config.image_upload_dir() <> ":")
  let assert Ok(_) = simplifile.create_directory_all(config.image_upload_dir())
  io.println("Uploads directory ensured")

  let registry = notifications.start_registry()
  io.println("Notification registry started")

  let assert Ok(_) =
    handler(_, conn, registry)
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(4000)
    |> mist.start

  process.sleep_forever()
}

fn handler(
  req: request.Request(mist.Connection),
  conn,
  registry: process.Subject(notifications.RegistryMessage),
) -> response.Response(mist.ResponseData) {
  let method = req.method |> http.method_to_string
  let segments = request.path_segments(req)

  io.println("[Info] " <> method <> " " <> req.path)

  case segments {
    ["ws"] -> handle_websocket(req, conn, registry)
    ["api", "images", image_id] if method == "GET" ->
      handle_image_get(conn, image_id)
    ["api", ..rest] -> route_via_oaspec(method, rest, req, conn, registry)
    _ -> respond_not_found()
  }
}

fn handle_websocket(
  req: request.Request(mist.Connection),
  conn,
  registry: process.Subject(notifications.RegistryMessage),
) -> response.Response(mist.ResponseData) {
  mist.websocket(
    req,
    on_init: fn(_ws_conn) {
      let subject = process.new_subject()
      let state =
        notifications.WsState(
          authenticated: False,
          user_id: None,
          notify_subject: Some(subject),
        )
      let _ = process.send_after(subject, 5000, notifications.AuthTimeout)
      let selector = process.new_selector() |> process.select(for: subject)
      #(state, Some(selector))
    },
    handler: fn(state, msg, ws_conn) {
      case msg {
        mist.Text(text) -> handle_ws_text(state, text, ws_conn, conn, registry)
        mist.Closed -> handle_ws_close(state, registry)
        mist.Shutdown -> handle_ws_close(state, registry)
        mist.Custom(event) -> handle_ws_custom(state, event, ws_conn)
        mist.Binary(_) -> mist.continue(state)
      }
    },
    on_close: fn(state) {
      case state.user_id, state.notify_subject {
        Some(uid), Some(subj) ->
          process.send(registry, notifications.Unregister(uid, subj))
        _, _ -> Nil
      }
    },
  )
}

fn handle_ws_text(
  state: notifications.WsState,
  text: String,
  ws_conn: mist.WebsocketConnection,
  conn,
  registry: process.Subject(notifications.RegistryMessage),
) -> mist.Next(notifications.WsState, notifications.WsEvent) {
  case state.authenticated {
    True -> {
      let _ = io.println("[ws] Received text after auth, ignoring")
      mist.continue(state)
    }
    False -> {
      let result = decode_auth_message(text)
      case result {
        Error(_) -> {
          let _ = io.println("[ws] Invalid auth message")
          let _ =
            mist.send_text_frame(
              ws_conn,
              "{\"type\":\"auth\",\"status\":\"error\"}",
            )
          mist.stop()
        }
        Ok(token) -> {
          case auth.verify_token(conn, token) {
            Error(_) -> {
              let _ = io.println("[ws] Invalid token")
              let _ =
                mist.send_text_frame(
                  ws_conn,
                  "{\"type\":\"auth\",\"status\":\"error\"}",
                )
              mist.stop()
            }
            Ok(user) -> {
              let auth_state =
                notifications.WsState(
                  ..state,
                  authenticated: True,
                  user_id: Some(user.id),
                )
              case auth_state.notify_subject {
                Some(subj) ->
                  process.send(registry, notifications.Register(user.id, subj))
                None -> Nil
              }
              let _ =
                io.println("[ws] Authenticated user " <> int.to_string(user.id))
              let _ =
                mist.send_text_frame(
                  ws_conn,
                  "{\"type\":\"auth\",\"status\":\"ok\"}",
                )
              mist.continue(auth_state)
            }
          }
        }
      }
    }
  }
}

fn handle_ws_close(
  state: notifications.WsState,
  registry: process.Subject(notifications.RegistryMessage),
) -> mist.Next(notifications.WsState, notifications.WsEvent) {
  case state.user_id, state.notify_subject {
    Some(uid), Some(subj) ->
      process.send(registry, notifications.Unregister(uid, subj))
    _, _ -> Nil
  }
  mist.stop()
}

fn handle_ws_custom(
  state: notifications.WsState,
  event: notifications.WsEvent,
  ws_conn: mist.WebsocketConnection,
) -> mist.Next(notifications.WsState, notifications.WsEvent) {
  case event {
    notifications.AuthTimeout -> {
      case state.authenticated {
        False -> {
          let _ = io.println("[ws] Auth timeout, closing")
          let _ =
            mist.send_text_frame(
              ws_conn,
              "{\"type\":\"auth\",\"status\":\"timeout\"}",
            )
          mist.stop()
        }
        True -> mist.continue(state)
      }
    }
    notifications.NotifyEvent(payload) -> {
      let user_str = case state.user_id {
        Some(uid) -> int.to_string(uid)
        None -> "?"
      }
      let _ = io.println("[ws] Sending notification to user " <> user_str)
      let _ = mist.send_text_frame(ws_conn, payload)
      mist.continue(state)
    }
    notifications.CloseConnection -> {
      mist.stop()
    }
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
              let filepath =
                config.image_upload_dir() <> "/" <> raw_image_id <> "." <> ext

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
  registry: process.Subject(notifications.RegistryMessage),
) -> response.Response(mist.ResponseData) {
  let bearer_token = extract_bearer_token(req.headers)

  let body_str = case mist.read_body(req, config.max_upload_limit()) {
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
            Ok(_user) -> {
              let app_state =
                handlers.State(
                  conn: conn,
                  bearer_token: Some(token),
                  registry: registry,
                )
              let serv_resp =
                router.route(
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
      let app_state =
        handlers.State(
          conn: conn,
          bearer_token: bearer_token,
          registry: registry,
        )
      let serv_resp =
        router.route(
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
    "POST", ["rent-requests", _, "offers"] -> True
    "POST", ["offers", _, "accept"] -> True
    "POST", ["rent-requests", _, "confirm-borrow"] -> True
    "POST", ["rent-requests", _, "confirm-return"] -> True
    _, _ -> False
  }
}

fn extract_bearer_token(headers: List(#(String, String))) -> Option(String) {
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

fn do_find_auth_header(headers: List(#(String, String))) -> Option(String) {
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

fn decode_auth_message(text: String) -> Result(String, Nil) {
  use obj <- result.try(
    json.parse(text, using: decode.dict(decode.string, decode.string))
    |> result.map_error(fn(_) { Nil }),
  )
  use raw_type <- result.try(
    dict.get(obj, "type") |> result.map_error(fn(_) { Nil }),
  )
  use raw_token <- result.try(
    dict.get(obj, "token") |> result.map_error(fn(_) { Nil }),
  )
  case raw_type {
    "auth" -> Ok(raw_token)
    _ -> Error(Nil)
  }
}

fn to_mist_response(
  serv_resp: router.ServerResponse,
) -> response.Response(mist.ResponseData) {
  let resp = response.new(serv_resp.status)

  let resp =
    list.fold(serv_resp.headers, resp, fn(r, header) {
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
