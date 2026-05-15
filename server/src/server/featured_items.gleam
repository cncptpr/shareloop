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
  let parsed = parse_latlng(get_query_param(req, "location"))
  let has_location = parsed.valid
  let lat_val = parsed.lat
  let lng_val = parsed.lng

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

type ParsedLocation {
  ParsedLocation(valid: Bool, lat: Float, lng: Float)
}

fn parse_latlng(raw: Result(String, Nil)) -> ParsedLocation {
  case raw {
    Ok(raw) -> {
      let parts = string.split(raw, "lat=")
      case parts {
        [_, rest] -> {
          let lat_lng_parts = string.split(rest, ", lng=")
          case lat_lng_parts {
            [lat_str, lng_rest] -> {
              let lng_str = string.replace(lng_rest, "]", "")
              let lat = float.parse(lat_str)
              let lng = float.parse(lng_str)
              case lat, lng {
                Ok(l), Ok(n) -> ParsedLocation(True, l, n)
                _, _ -> ParsedLocation(False, 0.0, 0.0)
              }
            }
            _ -> ParsedLocation(False, 0.0, 0.0)
          }
        }
        _ -> ParsedLocation(False, 0.0, 0.0)
      }
    }
    _ -> ParsedLocation(False, 0.0, 0.0)
  }
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
