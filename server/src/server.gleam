import generated/routes
import gleam/bytes_tree
import gleam/erlang/process
import gleam/http
import gleam/http/request
import gleam/http/response
import gleam/io
import mist
import server/auth/handlers
import server/db
import server/featured_items
import server/images
import server/items
import server/migration

pub fn main() {
  let assert Ok(conn) = db.start_pool()
  io.println("Database pool started")

  let assert Ok(_) = migration.run_all()
  io.println("Migrations applied")

  let assert Ok(_) =
    router(_, conn)
    |> mist.new
    |> mist.bind("0.0.0.0")
    |> mist.port(4000)
    |> mist.start

  process.sleep_forever()
}

fn router(req: request.Request(mist.Connection), conn) {
  io.println(
    "[Info] Request for "
    <> req.method |> http.method_to_string
    <> " "
    <> req.path,
  )
  case request.path_segments(req) {
    ["api", ..segments] -> openapi_router(req.method, segments, req, conn)
    _ -> handle404()
  }
}

fn openapi_router(method, segments, req, conn) {
  case routes.match_route(method, segments) {
    routes.GetFeaturedItems -> featured_items.handle(req, conn)
    routes.CreateItem -> items.create_handle(req, conn)
    routes.GetItem(item_id) -> items.get_handle(req, conn, item_id)
    routes.UploadItemImage(item_id) -> images.upload_handle(req, conn, item_id)
    routes.GetImage(image_id) -> images.get_handle(req, conn, image_id)
    routes.NotFound -> handle404()
    routes.Login -> handlers.login(req, conn)
    routes.Logout -> handlers.logout(req, conn)
    routes.Refresh -> handlers.refresh(req, conn)
    routes.Verify -> handlers.verify(req, conn)
  }
}

fn handle404() {
  response.new(404) |> response.set_body(mist.Bytes(bytes_tree.new()))
}
