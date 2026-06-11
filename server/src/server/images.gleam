import generated/types
import gleam/bit_array
import gleam/bytes_tree
import gleam/dynamic/decode
import gleam/http/request
import gleam/http/response
import gleam/int
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{None}
import gleam/result
import gleam/string
import mist
import pog
import server/auth/helpers
import server/consts.{max_upload_limit}
import server/sql
import simplifile
import youid/uuid

pub fn upload_handle(
  req: request.Request(mist.Connection),
  conn,
  item_id raw_item_id: String,
) -> response.Response(mist.ResponseData) {
  case try_upload(req, conn, raw_item_id) {
    Ok(uuid_string) -> respond_created(uuid_string)
    Error(status) -> respond_error(status)
  }
}

pub fn get_handle(
  req: request.Request(mist.Connection),
  conn,
  image_id: String,
) -> response.Response(mist.ResponseData) {
  case try_get(req, conn, image_id) {
    Ok(resp) -> resp
    Error(status) -> respond_error(status)
  }
}

fn try_upload(req, conn, raw_item_id) -> Result(String, Int) {
  use user <- result.try(
    helpers.verify_request(req, conn)
    |> result.map_error(fn(_) {
      io.println("[images] Auth failed")
      401
    }),
  )

  let item_id =
    int.parse(raw_item_id)
    |> result.map_error(fn(_) {
      io.println("[images] Invalid item_id: " <> raw_item_id)
      400
    })

  use item_id <- result.try(item_id)

  io.println(
    "[images] Authed as: "
    <> user.email
    <> " for item "
    <> int.to_string(item_id),
  )

  use req <- result.try(
    mist.read_body(req, consts.max_upload_limit())
    |> result.map_error(fn(_) {
      io.println("[images] Body too large")
      413
    }),
  )

  use str <- result.try(
    bit_array.to_string(req.body)
    |> result.map_error(fn(_) {
      io.println("[images] Body not valid UTF-8")
      400
    }),
  )

  use types.UploadItemImageRequest(data:, filename:, sort_order:) <- result.try(
    json.parse(str, types.upload_item_image_request_decoder())
    |> result.map_error(fn(_) {
      io.println("[images] Invalid JSON body")
      400
    }),
  )

  use image_bytes <- result.try(
    bit_array.base64_decode(data)
    |> result.map_error(fn(_) {
      io.println("[images] Invalid base64 data")
      400
    }),
  )

  let #(ext, mime) = detect_ext_and_mime(filename)

  let image_uuid = uuid.v4()
  let uuid_string = uuid.to_string(image_uuid)
  let disk_filename = uuid_string <> "." <> ext
  let filepath = "uploads/" <> disk_filename

  // Verify the authenticated user owns the item
  use _ <- result.try(
    verify_item_owner(conn, item_id, user.id)
    |> result.map_error(fn(msg) {
      io.println("[images] " <> msg)
      403
    }),
  )

  // Write image to disk
  use _ <- result.try(
    simplifile.write_bits(filepath, image_bytes)
    |> result.map_error(fn(_) {
      io.println("[images] Failed to write file: " <> filepath)
      500
    }),
  )

  io.println("[images] Wrote " <> filepath)

  // Insert DB record
  use result <- result.try(
    sql.insert_item_image(conn, image_uuid, item_id, filename, mime, sort_order)
    |> result.map_error(fn(e) {
      io.println("[images] DB error: " <> string.inspect(e))
      // Clean up file on DB failure
      let _ = simplifile.delete_file(filepath)
      500
    }),
  )

  use row <- result.try(
    result.rows
    |> list.first
    |> result.map_error(fn(_) {
      io.println("[images] No row returned")
      500
    }),
  )

  io.println("[images] Created image id=" <> uuid.to_string(row.id))
  Ok(uuid_string)
}

fn try_get(
  _req,
  conn,
  raw_image_id: String,
) -> Result(response.Response(mist.ResponseData), Int) {
  use image_uuid <- result.try(
    uuid.from_string(raw_image_id)
    |> result.map_error(fn(_) {
      io.println("[images] Invalid image ID: " <> raw_image_id)
      400
    }),
  )

  use result <- result.try(
    sql.get_item_image(conn, image_uuid)
    |> result.map_error(fn(e) {
      io.println("[images] DB error: " <> string.inspect(e))
      500
    }),
  )

  use row <- result.try(
    result.rows
    |> list.first
    |> result.map_error(fn(_) {
      io.println("[images] Image not found: " <> raw_image_id)
      404
    }),
  )

  let disk_filename = raw_image_id <> "." <> mime_to_ext(row.mime_type)
  let filepath = "uploads/" <> disk_filename

  use file_result <- result.try(
    mist.send_file(filepath, offset: 0, limit: None)
    |> result.map_error(fn(_) {
      io.println("[images] File not found on disk: " <> filepath)
      500
    }),
  )

  Ok(
    response.new(200)
    |> response.prepend_header("content-type", row.mime_type)
    |> response.set_body(file_result),
  )
}

fn verify_item_owner(conn, item_id: Int, user_id: Int) -> Result(Nil, String) {
  // Check that the item exists and belongs to the authenticated user
  // We use a simple query via pog directly since there's no squirrel query for this
  let sql = "select author_id from items where id = $1"
  let decoder = {
    use author_id <- decode.field(0, decode.int)
    decode.success(author_id)
  }

  use result <- result.try(
    sql
    |> pog.query
    |> pog.parameter(pog.int(item_id))
    |> pog.returning(decoder)
    |> pog.execute(conn)
    |> result.map_error(fn(_) { "Item query failed" }),
  )

  use author_id <- result.try(
    result.rows |> list.first |> result.map_error(fn(_) { "Item not found" }),
  )

  case author_id == user_id {
    True -> Ok(Nil)
    False -> Error("User does not own this item")
  }
}

fn detect_ext_and_mime(filename: String) -> #(String, String) {
  let parts = string.split(filename, ".")
  let ext = case list.last(parts) {
    Ok("jpg") -> "jpg"
    Ok("jpeg") -> "jpg"
    Ok("png") -> "png"
    Ok("gif") -> "gif"
    Ok("webp") -> "webp"
    _ -> "jpg"
  }
  let mime = case ext {
    "png" -> "image/png"
    "gif" -> "image/gif"
    "webp" -> "image/webp"
    _ -> "image/jpeg"
  }
  #(ext, mime)
}

fn mime_to_ext(mime: String) -> String {
  case mime {
    "image/png" -> "png"
    "image/gif" -> "gif"
    "image/webp" -> "webp"
    _ -> "jpg"
  }
}

fn respond_created(uuid_string: String) {
  let body =
    types.UploadItemImageResponse(uuid: uuid_string)
    |> types.encode_upload_item_image_response
    |> json.to_string
  response.new(201)
  |> response.prepend_header("content-type", "application/json")
  |> response.set_body(mist.Bytes(bytes_tree.from_string(body)))
}

fn respond_error(status: Int) {
  response.new(status)
  |> response.set_body(mist.Bytes(bytes_tree.new()))
}
