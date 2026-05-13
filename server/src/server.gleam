import cigogne
import cigogne/config
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http/request
import gleam/http/response
import mist
import server/featured_items

pub fn main() {
  run_migrations()

  let assert Ok(_) =
    router
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(4000)
    |> mist.start

  process.sleep_forever()
}

fn run_migrations() {
  case config.get("server") {
    Ok(cfg) -> {
      case cigogne.create_engine(cfg) {
        Ok(engine) -> {
          let assert Ok(Nil) = cigogne.apply_all(engine)
          Nil
        }
        Error(_) -> Nil
      }
    }
    Error(_) -> Nil
  }
}

fn router(req) {
  case request.path_segments(req) {
    ["api", "featured-items"] -> featured_items.handle()
    _ -> response.new(404) |> response.set_body(mist.Bytes(bytes_tree.new()))
  }
}
