import generated/types
import gleam/bytes_tree
import gleam/http/request
import gleam/http/response
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{None, Some}
import gleam/result
import gleam/string
import mist
import pog
import server/auth/helpers
import server/parser
import server/sql
import simplifile
import youid/uuid

pub fn create_handle(
  req: request.Request(mist.Connection),
  conn,
) -> response.Response(mist.ResponseData) {
  case try_create(req, conn) {
    Ok(response) -> respond_created(response)
    Error(status) -> respond_error(status)
  }
}

pub fn get_handle(
  req: request.Request(mist.Connection),
  conn,
  raw_item_id: String,
) -> response.Response(mist.ResponseData) {
  case try_get(req, conn, raw_item_id) {
    Ok(item) -> respond_ok(item)
    Error(status) -> respond_error(status)
  }
}

pub fn update_handle(
  req: request.Request(mist.Connection),
  conn,
  raw_item_id: String,
) -> response.Response(mist.ResponseData) {
  case try_update(req, conn, raw_item_id) {
    Ok(item) -> respond_updated(item)
    Error(status) -> respond_error(status)
  }
}

pub fn edit_images_handle(
  req: request.Request(mist.Connection),
  conn,
  raw_item_id: String,
) -> response.Response(mist.ResponseData) {
  case try_edit_images(req, conn, raw_item_id) {
    Ok(_) -> respond_no_content()
    Error(status) -> respond_error(status)
  }
}

fn try_create(req, conn) -> Result(types.CreateItemResponse, Int) {
  use user <- result.try(
    helpers.verify_request(req, conn) |> result.map_error(fn(_) {
      io.println("[items] Auth failed")
      401
    }),
  )

  io.println("[items] Authed as: " <> user.email)

  use types.CreateItemRequest(
    title:,
    description:,
    city:,
    postal_code:,
    lat:,
    lng:,
  ) <- result.try(
    parser.parse_json_body(req, types.create_item_request_decoder)
    |> result.map_error(fn(_) {
      io.println("[items] Invalid body")
      400
    }),
  )

  case city == "" || postal_code == "" {
    True -> {
      io.println("[items] city and postal_code must not be empty")
      Error(400)
    }
    False -> {
      io.println("[items] Creating: " <> title)

      use result <- result.try(
        sql.create_item(
          conn,
          title,
          description,
          user.id,
          0.0,
          lng,
          lat,
          city,
          postal_code,
        )
        |> result.map_error(fn(e) {
          io.println("[items] DB error: " <> string.inspect(e))
          500
        }),
      )

      use row <- result.try(
        result.rows |> list.first |> result.map_error(fn(_) {
          io.println("[items] No row returned")
          500
        }),
      )

      io.println("[items] Created item id=" <> int.to_string(row.id))
      Ok(types.CreateItemResponse(id: row.id))
    }
  }
}

fn try_get(_req, conn, raw_item_id: String) -> Result(types.ItemDetail, Int) {
  use item_id <- result.try(
    int.parse(raw_item_id)
    |> result.map_error(fn(_) {
      io.println("[items] Invalid item_id: " <> raw_item_id)
      400
    }),
  )

  io.println("[items] Fetching item " <> int.to_string(item_id))

  use result <- result.try(
    sql.get_item_by_id(conn, item_id)
    |> result.map_error(fn(e) {
      io.println("[items] DB error: " <> string.inspect(e))
      500
    }),
  )

  use row <- result.try(
    result.rows |> list.first |> result.map_error(fn(_) {
      io.println("[items] Item not found: " <> raw_item_id)
      404
    }),
  )

  use images_result <- result.try(
    sql.get_item_images_for_item(conn, item_id)
    |> result.map_error(fn(e) {
      io.println("[items] DB error fetching images: " <> string.inspect(e))
      500
    }),
  )

  let image_uuids = list.map(images_result.rows, fn(img_row) {
    uuid.to_string(img_row.id)
  })

  Ok(types.ItemDetail(
    id: row.id,
    title: row.title,
    description: row.description,
    author: types.Person(name: row.author_name),
    score: row.score,
    city: row.city,
    postal_code: row.postal_code,
    image_uuids: Some(image_uuids),
    category: None,
    lat: row.lat,
    lng: row.lng,
    created_at: row.created_at,
    author_id: row.author_id,
  ))
}

fn try_update(req, conn, raw_item_id: String) -> Result(types.CreateItemResponse, Int) {
  use user <- result.try(
    helpers.verify_request(req, conn) |> result.map_error(fn(_) {
      io.println("[items] Auth failed")
      401
    }),
  )

  use item_id <- result.try(
    int.parse(raw_item_id) |> result.map_error(fn(_) {
      io.println("[items] Invalid item_id: " <> raw_item_id)
      400
    }),
  )

  use types.UpdateItemRequest(
    title:, description:, city:, postal_code:, lat:, lng:,
  ) <- result.try(
    parser.parse_json_body(req, types.update_item_request_decoder)
    |> result.map_error(fn(_) {
      io.println("[items] Invalid body")
      400
    }),
  )

  use _ <- result.try(
    case city == "" || postal_code == "" {
      True -> {
        io.println("[items] city and postal_code must not be empty")
        Error(Nil)
      }
      False -> Ok(Nil)
    }
    |> result.map_error(fn(_) { 400 }),
  )

  use item_result <- result.try(
    sql.get_item_by_id(conn, item_id) |> result.map_error(fn(e) {
      io.println("[items] DB error: " <> string.inspect(e))
      500
    }),
  )

  use item_row <- result.try(
    item_result.rows |> list.first |> result.map_error(fn(_) {
      io.println("[items] Item not found: " <> raw_item_id)
      404
    }),
  )

  case item_row.author_id == user.id {
    False -> Error(403)
    True -> {
      use result <- result.try(
        sql.update_item(conn, title, description, city, postal_code, lng, lat, item_id, user.id)
        |> result.map_error(fn(e) {
          io.println("[items] DB error updating: " <> string.inspect(e))
          500
        }),
      )

      use row <- result.try(
        result.rows |> list.first |> result.map_error(fn(_) {
          io.println("[items] No row returned from update")
          500
        }),
      )

      io.println("[items] Updated item id=" <> int.to_string(row.id))
      Ok(types.CreateItemResponse(id: row.id))
    }
  }
}

fn try_edit_images(
  req: request.Request(mist.Connection),
  conn,
  raw_item_id: String,
) -> Result(Nil, Int) {
  use user <- result.try(
    helpers.verify_request(req, conn) |> result.map_error(fn(_) {
      io.println("[items] Auth failed")
      401
    }),
  )

  use item_id <- result.try(
    int.parse(raw_item_id) |> result.map_error(fn(_) {
      io.println("[items] Invalid item_id: " <> raw_item_id)
      400
    }),
  )

  use types.EditItemImagesRequest(delete: delete_uuids, reorder:) <- result.try(
    parser.parse_json_body(req, types.edit_item_images_request_decoder)
    |> result.map_error(fn(_) {
      io.println("[items] Invalid body")
      400
    }),
  )

  use item_result <- result.try(
    sql.get_item_by_id(conn, item_id) |> result.map_error(fn(e) {
      io.println("[items] DB error: " <> string.inspect(e))
      500
    }),
  )

  use item_row <- result.try(
    item_result.rows |> list.first |> result.map_error(fn(_) {
      io.println("[items] Item not found: " <> raw_item_id)
      404
    }),
  )

  case item_row.author_id == user.id {
    False -> Error(403)
    True -> {
      list.each(delete_uuids, fn(uuid_string) {
        case uuid.from_string(uuid_string) {
          Error(_) -> io.println("[items] Invalid UUID in delete: " <> uuid_string)
          Ok(parsed_uuid) -> {
            let _ = do_delete_image(conn, item_id, parsed_uuid, uuid_string)
            Nil
          }
        }
      })

      list.each(reorder, fn(entry: types.ReorderEntry) {
        case uuid.from_string(entry.uuid) {
          Error(_) -> io.println("[items] Invalid UUID in reorder: " <> entry.uuid)
          Ok(parsed_uuid) -> {
            let _ = sql.update_item_image_sort_order(conn, parsed_uuid, item_id, entry.sort_order)
            Nil
          }
        }
      })

      Ok(Nil)
    }
  }
}

fn do_delete_image(
  conn: pog.Connection,
  item_id: Int,
  image_uuid: uuid.Uuid,
  uuid_string: String,
) -> Nil {
  case sql.delete_item_image(conn, image_uuid, item_id) {
    Error(e) -> {
      io.println("[items] DB error deleting image: " <> string.inspect(e))
      Nil
    }
    Ok(result) -> {
      case result.rows {
        [] -> Nil
        [row, ..] -> {
          let ext = detect_ext(row.original_name)
          let filepath = "uploads/" <> uuid_string <> "." <> ext
          let _ = simplifile.delete_file(filepath)
          Nil
        }
      }
    }
  }
}

fn detect_ext(filename: String) -> String {
  let parts = string.split(filename, ".")
  case list.last(parts) {
    Ok("jpg") -> "jpg"
    Ok("jpeg") -> "jpg"
    Ok("png") -> "png"
    Ok("gif") -> "gif"
    Ok("webp") -> "webp"
    _ -> "jpg"
  }
}

fn respond_created(item: types.CreateItemResponse) {
  let body =
    item
    |> types.encode_create_item_response
    |> json.to_string
  response.new(201)
  |> response.prepend_header("content-type", "application/json")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

fn respond_ok(item: types.ItemDetail) {
  let body =
    item
    |> types.encode_item_detail
    |> json.to_string
  response.new(200)
  |> response.prepend_header("content-type", "application/json")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

fn respond_updated(item: types.CreateItemResponse) {
  let body =
    item
    |> types.encode_create_item_response
    |> json.to_string
  response.new(200)
  |> response.prepend_header("content-type", "application/json")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

fn respond_no_content() {
  response.new(204) |> response.set_body(mist.Bytes(bytes_tree.new()))
}

fn respond_error(status: Int) {
  response.new(status)
  |> response.set_body(mist.Bytes(bytes_tree.new()))
}
