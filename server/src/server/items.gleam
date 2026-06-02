import generated/types
import gleam/bytes_tree
import gleam/http/request
import gleam/http/response
import gleam/io
import gleam/int
import gleam/json
import gleam/list
import gleam/result
import gleam/string
import mist
import server/auth/helpers
import server/parser
import server/sql

pub fn handle(
  req: request.Request(mist.Connection),
  conn,
) -> response.Response(mist.ResponseData) {
  case try_create(req, conn) {
    Ok(response) -> respond(response)
    Error(status) -> respond_error(status)
  }
}

fn try_create(req, conn) -> Result(types.CreateItemResponse, Int) {
  use user <- result.try(
    helpers.verify_request(req, conn) |> result.map_error(fn(_) {
      io.println("[items] Auth failed")
      401
    }),
  )

  io.println("[items] Authed as: " <> user.email)

  use types.CreateItemRequest(
    title:,
    description:,
    city:,
    postal_code:,
    lat:,
    lng:,
  ) <- result.try(
    parser.parse_json_body(req, types.create_item_request_decoder)
    |> result.map_error(fn(_) {
      io.println("[items] Invalid body")
      400
    }),
  )

  io.println("[items] Creating: " <> title)

  use result <- result.try(
    sql.create_item(conn, title, description, user.id, 0.0, lng, lat, city, postal_code)
    |> result.map_error(fn(e) {
      io.println("[items] DB error: " <> string.inspect(e))
      500
    }),
  )

  use row <- result.try(
    result.rows |> list.first |> result.map_error(fn(_) {
      io.println("[items] No row returned")
      500
    }),
  )

  io.println("[items] Created item id=" <> int.to_string(row.id))
  Ok(types.CreateItemResponse(id: row.id))
}

fn respond(item: types.CreateItemResponse) {
  let body =
    item
    |> types.encode_create_item_response
    |> json.to_string
  response.new(201)
  |> response.prepend_header("content-type", "application/json")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

fn respond_error(status: Int) {
  response.new(status)
  |> response.set_body(mist.Bytes(bytes_tree.new()))
}
