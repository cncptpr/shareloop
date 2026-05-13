import generated/types
import gleam/bytes_tree
import gleam/http/response
import gleam/json
import mist

pub fn handle() -> response.Response(mist.ResponseData) {
  let items = mock()
  let body = json.array(items, types.encode_featured_item) |> json.to_string
  response.new(200)
  |> response.prepend_header("content-type", "application/json")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

fn mock() {
  [
    types.FeaturedItem(
      title: "Inserat 1",
      description: "Ganz tolles Inserat",
      author: types.Person(name: "Ich"),
      distance: types.Distance(km: 8.3),
      score: 4.9,
    ),
    types.FeaturedItem(
      title: "Internat",
      description: "Ganz tolles Internat",
      author: types.Person(name: "Ich"),
      distance: types.Distance(km: 8.3),
      score: 4.9,
    ),
    types.FeaturedItem(
      title: "Inserat 2",
      description: "Papput",
      author: types.Person(name: "Ich"),
      distance: types.Distance(km: 8.3),
      score: 4.9,
    ),
    types.FeaturedItem(
      title: "Auto",
      description: "Kann fahren",
      author: types.Person(name: "Carl"),
      distance: types.Distance(km: 8.3),
      score: 4.3,
    ),
    types.FeaturedItem(
      title: "Spezi",
      description: "Bitte voll zurueck",
      author: types.Person(name: "Timon"),
      distance: types.Distance(km: 2.3),
      score: 5.0,
    ),
  ]
}
