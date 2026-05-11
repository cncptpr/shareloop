import gleam/bytes_tree
import gleam/http/response
import gleam/json
import mist
import server/api

pub fn handle() -> response.Response(mist.ResponseData) {
  let items = mock()
  let body = json.array(items, api.featured_item_to_json) |> json.to_string
  response.new(200)
  |> response.prepend_header("content-type", "application/json")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

fn mock() {
  [
    api.FeaturedItem(
      title: "Inserat 1",
      description: "Ganz tolles Inserat",
      author: api.Person(name: "Ich"),
      distance: api.Distance(km: 8.3),
      score: 4.9,
    ),
    api.FeaturedItem(
      title: "Internat",
      description: "Ganz tolles Internat",
      author: api.Person(name: "Ich"),
      distance: api.Distance(km: 8.3),
      score: 4.9,
    ),
    api.FeaturedItem(
      title: "Inserat 2",
      description: "Papput",
      author: api.Person(name: "Ich"),
      distance: api.Distance(km: 8.3),
      score: 4.9,
    ),
    api.FeaturedItem(
      title: "Auto",
      description: "Kann fahren",
      author: api.Person(name: "Carl"),
      distance: api.Distance(km: 8.3),
      score: 4.3,
    ),
    api.FeaturedItem(
      title: "Spezi",
      description: "Bitte voll zurueck",
      author: api.Person(name: "Timon"),
      distance: api.Distance(km: 2.3),
      score: 5.0,
    ),
  ]
}
