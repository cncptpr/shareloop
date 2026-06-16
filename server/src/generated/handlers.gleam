import generated/request_types
import generated/response_types
import generated/types
import gleam/bit_array
import gleam/dynamic/decode
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import pog
import server/auth
import server/featured_items
import server/sql
import simplifile
import youid/uuid

pub type State {
  State(conn: pog.Connection, bearer_token: Option(String))
}

fn verify_auth(state: State) -> Result(types.User, Nil) {
  case state.bearer_token {
    None -> Error(Nil)
    Some(token) ->
      auth.verify_token(state.conn, token) |> result.map_error(fn(_) { Nil })
  }
}

pub fn login(
  state: State,
  req: request_types.LoginRequest,
) -> response_types.LoginResponse {
  case auth.login(state.conn, req.body.email, req.body.password) {
    Ok(result) -> response_types.LoginResponseOk(result)
    Error(_) -> response_types.LoginResponseUnauthorized
  }
}

pub fn logout(state: State) -> response_types.LogoutResponse {
  case verify_auth(state) {
    Error(_) -> response_types.LogoutResponseUnauthorized
    Ok(_user) -> {
      case state.bearer_token {
        None -> response_types.LogoutResponseUnauthorized
        Some(token) -> {
          case auth.logout(state.conn, token) {
            Ok(_) -> response_types.LogoutResponseNoContent
            Error(_) -> response_types.LogoutResponseUnauthorized
          }
        }
      }
    }
  }
}

pub fn refresh(
  state: State,
  req: request_types.RefreshRequest,
) -> response_types.RefreshResponse {
  case auth.refresh_session(state.conn, req.body.refresh_token) {
    Ok(result) -> response_types.RefreshResponseOk(result)
    Error(_) -> response_types.RefreshResponseUnauthorized
  }
}

pub fn verify(state: State) -> response_types.VerifyResponse {
  case verify_auth(state) {
    Error(_) -> response_types.VerifyResponseUnauthorized
    Ok(user) -> response_types.VerifyResponseOk(user)
  }
}

pub fn get_featured_items(
  state: State,
  req: request_types.GetFeaturedItemsRequest,
) -> response_types.GetFeaturedItemsResponse {
  let items = case req.body {
    None -> featured_items.get_featured_items_without_distance(state.conn)
    Some(lat_lng) -> featured_items.get_featured_items(state.conn, lat_lng)
  }
  response_types.GetFeaturedItemsResponseOk(items)
}

pub fn get_image(
  state: State,
  req: request_types.GetImageRequest,
) -> response_types.GetImageResponse {
  let _ = state
  let _ = req
  response_types.GetImageResponseOk("")
}

pub fn create_item(
  state: State,
  req: request_types.CreateItemRequest,
) -> response_types.CreateItemResponse {
  let body = req.body

  case verify_auth(state) {
    Error(_) ->
      response_types.CreateItemResponseCreated(types.CreateItemResponse(id: 0))
    Ok(user) -> {
      case body.city == "" || body.postal_code == "" {
        True -> {
          io.println("[handlers] city and postal_code must not be empty")
          response_types.CreateItemResponseCreated(types.CreateItemResponse(
            id: 0,
          ))
        }
        False -> {
          case
            sql.create_item(
              state.conn,
              body.title,
              body.description,
              user.id,
              0.0,
              body.lng,
              body.lat,
              body.city,
              body.postal_code,
            )
          {
            Ok(returned) ->
              case list.first(returned.rows) {
                Ok(row) ->
                  response_types.CreateItemResponseCreated(
                    types.CreateItemResponse(id: row.id),
                  )
                Error(_) -> {
                  io.println("[handlers] No row returned from create_item")
                  response_types.CreateItemResponseCreated(
                    types.CreateItemResponse(id: 0),
                  )
                }
              }
            Error(e) -> {
              io.println(
                "[handlers] DB error creating item: " <> string.inspect(e),
              )
              response_types.CreateItemResponseCreated(types.CreateItemResponse(
                id: 0,
              ))
            }
          }
        }
      }
    }
  }
}

pub fn get_item(
  state: State,
  req: request_types.GetItemRequest,
) -> response_types.GetItemResponse {
  let result = sql.get_item_by_id(state.conn, req.item_id)
  case result {
    Error(e) -> {
      io.println("[handlers] DB error: " <> string.inspect(e))
      response_types.GetItemResponseNotFound
    }
    Ok(returned) -> {
      case list.first(returned.rows) {
        Error(_) -> response_types.GetItemResponseNotFound
        Ok(row) -> {
          let images_result =
            sql.get_item_images_for_item(state.conn, req.item_id)
          let image_uuids = case images_result {
            Ok(r) ->
              list.map(r.rows, fn(img_row) { uuid.to_string(img_row.id) })
            Error(_) -> []
          }
          response_types.GetItemResponseOk(types.ItemDetail(
            id: row.id,
            title: row.title,
            description: row.description,
            author: types.Person(id: row.author_id, name: row.author_name),
            score: row.score,
            city: row.city,
            postal_code: row.postal_code,
            image_uuids: image_uuids,
            category: None,
            created_at: row.created_at,
          ))
        }
      }
    }
  }
}

type GetItemEditError {
  GetItemEditUnauthorized
  GetItemEditNotFound
  GetItemEditForbidden
}

fn try_get_item_edit(
  state: State,
  item_id: Int,
) -> Result(#(sql.GetItemByIdRow, List(String)), GetItemEditError) {
  use user <- result.try(
    verify_auth(state) |> result.map_error(fn(_) { GetItemEditUnauthorized }),
  )

  use returned <- result.try(
    sql.get_item_by_id(state.conn, item_id)
    |> result.map_error(fn(_) { GetItemEditNotFound }),
  )

  use row <- result.try(
    list.first(returned.rows)
    |> result.map_error(fn(_) { GetItemEditNotFound }),
  )

  case row.author_id == user.id {
    False -> Error(GetItemEditForbidden)
    True -> {
      let image_uuids = case sql.get_item_images_for_item(state.conn, item_id) {
        Ok(r) -> list.map(r.rows, fn(img_row) { uuid.to_string(img_row.id) })
        Error(_) -> []
      }
      Ok(#(row, image_uuids))
    }
  }
}

pub fn get_item_edit(
  state: State,
  req: request_types.GetItemEditRequest,
) -> response_types.GetItemEditResponse {
  case try_get_item_edit(state, req.item_id) {
    Ok(#(row, image_uuids)) ->
      response_types.GetItemEditResponseOk(types.ItemEditDetail(
        id: row.id,
        title: row.title,
        description: row.description,
        author: types.Person(id: row.author_id, name: row.author_name),
        score: row.score,
        city: row.city,
        postal_code: row.postal_code,
        image_uuids: image_uuids,
        category: None,
        lat: row.lat,
        lng: row.lng,
        created_at: row.created_at,
      ))
    Error(GetItemEditUnauthorized) -> response_types.GetItemEditResponseForbidden
    Error(GetItemEditNotFound) -> response_types.GetItemEditResponseNotFound
    Error(GetItemEditForbidden) -> response_types.GetItemEditResponseForbidden
  }
}

pub fn update_item(
  state: State,
  req: request_types.UpdateItemRequest,
) -> response_types.UpdateItemResponse {
  let body = req.body

  case body.city == "" || body.postal_code == "" {
    True -> response_types.UpdateItemResponseNotFound
    False -> {
      case verify_auth(state) {
        Error(_) -> response_types.UpdateItemResponseNotFound
        Ok(user) -> {
          case sql.get_item_by_id(state.conn, req.item_id) {
            Error(_) -> response_types.UpdateItemResponseNotFound
            Ok(r) ->
              case list.first(r.rows) {
                Error(_) -> response_types.UpdateItemResponseNotFound
                Ok(item_row) -> {
                  case item_row.author_id == user.id {
                    False -> response_types.UpdateItemResponseForbidden
                    True -> {
                      case
                        sql.update_item(
                          state.conn,
                          body.title,
                          body.description,
                          body.city,
                          body.postal_code,
                          body.lng,
                          body.lat,
                          req.item_id,
                          user.id,
                        )
                      {
                        Error(_) -> response_types.UpdateItemResponseNotFound
                        Ok(updated) ->
                          case list.first(updated.rows) {
                            Error(_) ->
                              response_types.UpdateItemResponseNotFound
                            Ok(row) ->
                              response_types.UpdateItemResponseOk(
                                types.CreateItemResponse(id: row.id),
                              )
                          }
                      }
                    }
                  }
                }
              }
          }
        }
      }
    }
  }
}

pub fn upload_item_image(
  state: State,
  req: request_types.UploadItemImageRequest,
) -> response_types.UploadItemImageResponse {
  let body = req.body

  case verify_auth(state) {
    Error(_) ->
      response_types.UploadItemImageResponseCreated(
        types.UploadItemImageResponse(uuid: ""),
      )
    Ok(user) -> {
      case bit_array.base64_decode(body.data) {
        Error(_) ->
          response_types.UploadItemImageResponseCreated(
            types.UploadItemImageResponse(uuid: ""),
          )
        Ok(image_bytes) -> {
          let #(ext, mime) = detect_ext_and_mime(body.filename)
          let image_uuid = uuid.v4()
          let uuid_string = uuid.to_string(image_uuid)
          let filepath = "uploads/" <> uuid_string <> "." <> ext

          case verify_item_owner(state.conn, req.item_id, user.id) {
            Error(_) ->
              response_types.UploadItemImageResponseCreated(
                types.UploadItemImageResponse(uuid: ""),
              )
            Ok(_) -> {
              case simplifile.write_bits(filepath, image_bytes) {
                Error(_) ->
                  response_types.UploadItemImageResponseCreated(
                    types.UploadItemImageResponse(uuid: ""),
                  )
                Ok(_) -> {
                  io.println("[handlers] Wrote " <> filepath)

                  case
                    sql.insert_item_image(
                      state.conn,
                      image_uuid,
                      req.item_id,
                      body.filename,
                      mime,
                      body.sort_order,
                    )
                  {
                    Error(e) -> {
                      io.println("[handlers] DB error: " <> string.inspect(e))
                      let _ = simplifile.delete_file(filepath)
                      response_types.UploadItemImageResponseCreated(
                        types.UploadItemImageResponse(uuid: ""),
                      )
                    }
                    Ok(returned) ->
                      case list.first(returned.rows) {
                        Error(_) ->
                          response_types.UploadItemImageResponseCreated(
                            types.UploadItemImageResponse(uuid: ""),
                          )
                        Ok(_row) -> {
                          io.println(
                            "[handlers] Created image id=" <> uuid_string,
                          )
                          response_types.UploadItemImageResponseCreated(
                            types.UploadItemImageResponse(uuid: uuid_string),
                          )
                        }
                      }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}

pub fn edit_item_images(
  state: State,
  req: request_types.EditItemImagesRequest,
) -> response_types.EditItemImagesResponse {
  case verify_auth(state) {
    Error(_) -> response_types.EditItemImagesResponseNoContent
    Ok(user) -> {
      case sql.get_item_by_id(state.conn, req.item_id) {
        Error(_) -> response_types.EditItemImagesResponseNoContent
        Ok(r) ->
          case list.first(r.rows) {
            Error(_) -> response_types.EditItemImagesResponseNoContent
            Ok(item_row) -> {
              case item_row.author_id == user.id {
                False -> response_types.EditItemImagesResponseNoContent
                True -> {
                  list.each(req.body.delete, fn(uuid_string) {
                    case uuid.from_string(uuid_string) {
                      Error(_) ->
                        io.println(
                          "[handlers] Invalid UUID in delete: " <> uuid_string,
                        )
                      Ok(parsed_uuid) -> {
                        let _ =
                          delete_image_file(
                            state.conn,
                            req.item_id,
                            parsed_uuid,
                            uuid_string,
                          )
                        Nil
                      }
                    }
                  })

                  list.each(req.body.reorder, fn(entry: types.ReorderEntry) {
                    case uuid.from_string(entry.uuid) {
                      Error(_) ->
                        io.println(
                          "[handlers] Invalid UUID in reorder: " <> entry.uuid,
                        )
                      Ok(parsed_uuid) -> {
                        let _ =
                          sql.update_item_image_sort_order(
                            state.conn,
                            parsed_uuid,
                            req.item_id,
                            entry.sort_order,
                          )
                        Nil
                      }
                    }
                  })

                  response_types.EditItemImagesResponseNoContent
                }
              }
            }
          }
      }
    }
  }
}

fn delete_image_file(
  conn: pog.Connection,
  item_id: Int,
  image_uuid: uuid.Uuid,
  uuid_string: String,
) -> Nil {
  case sql.delete_item_image(conn, image_uuid, item_id) {
    Error(e) ->
      io.println("[handlers] DB error deleting image: " <> string.inspect(e))
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

fn verify_item_owner(
  conn: pog.Connection,
  item_id: Int,
  user_id: Int,
) -> Result(Nil, String) {
  let sql_str = "select author_id from items where id = $1"
  let decoder = {
    use author_id <- decode.field(0, decode.int)
    decode.success(author_id)
  }

  use result <- result.try(
    sql_str
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
