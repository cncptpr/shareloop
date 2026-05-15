import generated/types
import gleam/bytes_tree
import gleam/float
import gleam/http/request
import gleam/http/response
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import mist
import server/sql

pub fn handle(
  req: request.Request(mist.Connection),
  conn,
) -> response.Response(mist.ResponseData) {
  let lat =
    get_query_param(req, "lat") |> result.map(float.parse) |> result.flatten
  let lng =
    get_query_param(req, "lng") |> result.map(float.parse) |> result.flatten

  let has_location = result.is_ok(lat) && result.is_ok(lng)
  let lat_val = result.unwrap(lat, 0.0)
  let lng_val = result.unwrap(lng, 0.0)

  let rows =
    sql.get_featured_items(conn, lat_val, lng_val)
    |> result.map(fn(returned) { returned.rows })
    |> result.unwrap([])

  let items =
    list.map(rows, fn(row) {
      types.FeaturedItem(
        title: row.title,
        description: row.description,
        author: types.Person(name: row.author_name),
        distance: case has_location {
          True -> Some(types.Distance(km: row.distance_km))
          False -> None
        },
        city: row.city,
        postal_code: row.postal_code,
        score: row.score,
      )
    })

  respond(items)
}

fn get_query_param(
  req: request.Request(a),
  name: String,
) -> Result(String, Nil) {
  case req.query {
    None -> Error(Nil)
    Some(query) -> {
      let pairs = string.split(query, "&")
      use pair <- result.try(
        list.find(pairs, fn(p) {
          case string.split(p, "=") {
            [k, _] if k == name -> True
            _ -> False
          }
        }),
      )
      case string.split(pair, "=") {
        [_, v] -> Ok(v)
        _ -> Error(Nil)
      }
    }
  }
}

fn respond(
  items: List(types.FeaturedItem),
) -> response.Response(mist.ResponseData) {
  let body = json.array(items, types.encode_featured_item) |> json.to_string
  response.new(200)
  |> response.prepend_header("content-type", "application/json")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}
