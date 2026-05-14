import generated/types
import gleam/bytes_tree
import gleam/http/response
import gleam/json
import gleam/list
import gleam/float
import mist
import server/db
import server/sql

pub fn handle(conn) -> response.Response(mist.ResponseData) {
  case sql.get_featured_items(conn) {
    Ok(returned) -> {
      let items = list.map(returned.rows, fn(row) {
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
    Error(_) -> respond([])
  }
}

fn respond(items: List(types.FeaturedItem)) -> response.Response(mist.ResponseData) {
  let body = json.array(items, types.encode_featured_item) |> json.to_string
  response.new(200)
  |> response.prepend_header("content-type", "application/json")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

fn random_distance() -> Float {
  // TODO: replace with real distance calculation
  float.random() *. 10.0
}
