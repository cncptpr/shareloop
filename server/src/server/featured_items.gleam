import generated/types
import gleam/bit_array
import gleam/bytes_tree
import gleam/http/request
import gleam/http/response
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import mist
import server/sql

const mega_byte = 1_048_576

pub fn handle(
  req: request.Request(mist.Connection),
  conn,
) -> response.Response(mist.ResponseData) {
  let location = decode_body(req)

  let items = case location {
    Some(location) -> get_featured_items(conn, location)
    None -> get_featured_items_without_distance(conn)
  }

  respond(items)
}

fn decode_body(req) {
  use req <- option.then(
    mist.read_body(req, max_body_limit: mega_byte)
    |> option.from_result,
  )

  use str <- option.then(bit_array.to_string(req.body) |> option.from_result)

  str |> json.parse(types.lat_lng_decoder()) |> option.from_result
}

fn get_featured_items(conn, location: types.LatLng) {
  sql.get_featured_items(conn, location.lat, location.lng)
  |> result.map(fn(returned) { returned.rows })
  |> result.unwrap([])
  |> list.map(fn(row) {
    types.FeaturedItem(
      title: row.title,
      description: row.description,
      author: types.Person(name: row.author_name),
      distance: Some(types.Distance(km: row.distance_km)),
      city: row.city,
      postal_code: row.postal_code,
      score: row.score,
    )
  })
}

fn get_featured_items_without_distance(conn) {
  sql.get_featured_items_without_distance(conn)
  |> result.map(fn(returned) { returned.rows })
  |> result.unwrap([])
  |> list.map(fn(row) {
    types.FeaturedItem(
      title: row.title,
      description: row.description,
      author: types.Person(name: row.author_name),
      distance: None,
      city: row.city,
      postal_code: row.postal_code,
      score: row.score,
    )
  })
}

fn respond(
  items: List(types.FeaturedItem),
) -> response.Response(mist.ResponseData) {
  let body = json.array(items, types.encode_featured_item) |> json.to_string
  response.new(200)
  |> response.prepend_header("content-type", "application/json")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}
