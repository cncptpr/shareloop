import generated/types
import gleam/bytes_tree
import gleam/float
import gleam/http/response
import gleam/json
import gleam/list
import gleam/result
import mist
import server/sql

pub fn handle(conn) -> response.Response(mist.ResponseData) {
  // TODO: add error handling to api instead of defaulting to an empty array on error
  let rows =
    sql.get_featured_items(conn)
    |> result.map(fn(returned) { returned.rows })
    |> result.unwrap([])
  let items =
    list.map(rows, fn(row) {
      types.FeaturedItem(
        title: row.title,
        description: row.description,
        author: types.Person(name: row.author_name),
        // TODO: replace with real distance calculation based on user location
        distance: types.Distance(km: random_distance()),
        score: row.score,
      )
    })
  respond(items)
}

fn respond(
  items: List(types.FeaturedItem),
) -> response.Response(mist.ResponseData) {
  let body = json.array(items, types.encode_featured_item) |> json.to_string
  response.new(200)
  |> response.prepend_header("content-type", "application/json")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

fn random_distance() -> Float {
  float.random() *. 10.0
}
