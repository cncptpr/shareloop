import cigogne
import cigogne/config
import generated/routes
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request.{type Request}
import gleam/http/response
import gleam/result
import mist
import server/error
import server/featured_items

pub fn main() {
  // TODO: make mirgrations happen
  let _ = run_migrations()

  let assert Ok(_) =
    router
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(4000)
    |> mist.start

  process.sleep_forever()
}

fn run_migrations() {
  use cfg <- error.try(config.get("server"), error.ConfigError)
  use engine <- error.try(cigogne.create_engine(cfg), error.CigogneError)
  cigogne.apply_all(engine) |> result.map_error(error.CigogneError)
}

fn router(req: Request(mist.Connection)) {
  case request.path_segments(req) {
    ["api", ..segments] -> openapi_router(req.method, segments)
    _ -> handle404()
  }
}

fn openapi_router(method, segments) {
  case routes.match_route(method, segments) {
    routes.GetFeaturedItems -> featured_items.handle()
    routes.NotFound -> handle404()
  }
}

fn handle404() {
  response.new(404) |> response.set_body(mist.Bytes(bytes_tree.new()))
}
