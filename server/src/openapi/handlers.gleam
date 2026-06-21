/// This file is safe to edit. It will not be overridden by oaspec.
import gleam/bit_array
import gleam/dynamic/decode
import gleam/erlang/process.{type Subject}
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import openapi/encode as openapi_encode
import openapi/request_types
import openapi/response_types
import openapi/types
import pog
import server/auth
import server/featured_items
import server/notifications
import server/renting
import server/search
import server/sql
import simplifile
import youid/uuid

pub type State {
  State(
    conn: pog.Connection,
    bearer_token: Option(String),
    registry: Subject(notifications.RegistryMessage),
  )
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

pub fn search_items(
  state: State,
  req: request_types.SearchItemsRequest,
) -> response_types.SearchItemsResponse {
  let items = case req.body {
    None -> []
    Some(body) -> search.search_items(state.conn, body)
  }
  response_types.SearchItemsResponseOk(items)
}

pub fn get_image(
  state: State,
  _req: request_types.GetImageRequest,
) -> response_types.GetImageResponse {
  let _ = state
  response_types.GetImageResponseNotFound
}

pub fn create_item(
  state: State,
  req: request_types.CreateItemRequest,
) -> response_types.CreateItemResponse {
  let body = req.body

  case verify_auth(state) {
    Error(_) -> response_types.CreateItemResponseUnauthorized
    Ok(user) -> {
      case body.city == "" || body.postal_code == "" {
        True -> {
          io.println("[handlers] city and postal_code must not be empty")
          response_types.CreateItemResponseInternalServerError
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
              body.category,
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
                  response_types.CreateItemResponseInternalServerError
                }
              }
            Error(e) -> {
              io.println(
                "[handlers] DB error creating item: " <> string.inspect(e),
              )
              response_types.CreateItemResponseInternalServerError
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
            category: row.category,
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
        category: row.category,
        lat: row.lat,
        lng: row.lng,
        created_at: row.created_at,
      ))
    Error(GetItemEditUnauthorized) ->
      response_types.GetItemEditResponseUnauthorized
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
        Error(_) -> response_types.UpdateItemResponseUnauthorized
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
                          body.category,
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
    Error(_) -> response_types.UploadItemImageResponseUnauthorized
    Ok(user) -> {
      case bit_array.base64_decode(body.data) {
        Error(_) -> response_types.UploadItemImageResponseInternalServerError
        Ok(image_bytes) -> {
          let #(ext, mime) = detect_ext_and_mime(body.filename)
          let image_uuid = uuid.v4()
          let uuid_string = uuid.to_string(image_uuid)
          let filepath = "uploads/" <> uuid_string <> "." <> ext

          case verify_item_owner(state.conn, req.item_id, user.id) {
            Error(_) -> response_types.UploadItemImageResponseForbidden
            Ok(_) -> {
              case simplifile.write_bits(filepath, image_bytes) {
                Error(_) ->
                  response_types.UploadItemImageResponseInternalServerError
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
                      response_types.UploadItemImageResponseInternalServerError
                    }
                    Ok(returned) ->
                      case list.first(returned.rows) {
                        Error(_) ->
                          response_types.UploadItemImageResponseInternalServerError
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
    Error(_) -> response_types.EditItemImagesResponseUnauthorized
    Ok(user) -> {
      case sql.get_item_by_id(state.conn, req.item_id) {
        Error(_) -> response_types.EditItemImagesResponseNotFound
        Ok(r) ->
          case list.first(r.rows) {
            Error(_) -> response_types.EditItemImagesResponseNotFound
            Ok(item_row) -> {
              case item_row.author_id == user.id {
                False -> response_types.EditItemImagesResponseForbidden
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

pub fn create_rent_request(
  state: State,
  req: request_types.CreateRentRequestRequest,
) -> response_types.CreateRentRequestResponse {
  case verify_auth(state) {
    Error(_) -> response_types.CreateRentRequestResponseUnauthorized
    Ok(user) -> {
      case renting.create_rent_request(state.conn, user.id, req.item_id) {
        Ok(request) -> response_types.CreateRentRequestResponseCreated(request)
        Error(_) -> response_types.CreateRentRequestResponseInternalServerError
      }
    }
  }
}

pub fn get_rent_requests(
  state: State,
) -> response_types.GetRentRequestsResponse {
  case verify_auth(state) {
    Error(_) -> response_types.GetRentRequestsResponseUnauthorized
    Ok(user) -> {
      case renting.get_rent_requests(state.conn, user.id) {
        Ok(requests) -> response_types.GetRentRequestsResponseOk(requests)
        Error(_) -> response_types.GetRentRequestsResponseInternalServerError
      }
    }
  }
}

pub fn get_rent_request(
  state: State,
  req: request_types.GetRentRequestRequest,
) -> response_types.GetRentRequestResponse {
  case verify_auth(state) {
    Error(_) -> response_types.GetRentRequestResponseUnauthorized
    Ok(user) -> {
      case renting.get_rent_request_by_id(state.conn, req.request_id, user.id) {
        Ok(request) -> {
          let messages_result =
            renting.get_messages(state.conn, req.request_id, user.id)
          let offers_result =
            renting.get_offers(state.conn, req.request_id, user.id)

          let messages = case messages_result {
            Ok(msgs) -> msgs
            _ -> []
          }
          let offers = case offers_result {
            Ok(ofs) -> ofs
            _ -> []
          }
          response_types.GetRentRequestResponseOk(
            types.RentRequestDetail(
              ..request,
              messages: messages,
              offers: offers,
            ),
          )
        }
        Error(_) -> response_types.GetRentRequestResponseNotFound
      }
    }
  }
}

pub fn send_message(
  state: State,
  req: request_types.SendMessageRequest,
) -> response_types.SendMessageResponse {
  case verify_auth(state) {
    Error(_) -> response_types.SendMessageResponseUnauthorized
    Ok(user) -> {
      case
        renting.send_message(
          state.conn,
          req.request_id,
          user.id,
          req.body.content,
        )
      {
        Ok(message) -> {
          let _ =
            notify_other_participant(
              state,
              req.request_id,
              user.id,
              "message.created",
              openapi_encode.encode_message_json(message),
            )
          response_types.SendMessageResponseCreated(message)
        }
        Error(_) -> response_types.SendMessageResponseInternalServerError
      }
    }
  }
}

pub fn create_offer(
  state: State,
  req: request_types.CreateOfferRequest,
) -> response_types.CreateOfferResponse {
  case verify_auth(state) {
    Error(_) -> response_types.CreateOfferResponseUnauthorized
    Ok(user) -> {
      case
        renting.create_offer(
          state.conn,
          req.request_id,
          user.id,
          req.body.start_date,
          req.body.end_date,
        )
      {
        Ok(offer) -> {
          let _ =
            notify_other_participant(
              state,
              req.request_id,
              user.id,
              "offer.created",
              openapi_encode.encode_rent_offer_json(offer),
            )
          response_types.CreateOfferResponseCreated(offer)
        }
        Error(_) -> response_types.CreateOfferResponseInternalServerError
      }
    }
  }
}

pub fn accept_offer(
  state: State,
  req: request_types.AcceptOfferRequest,
) -> response_types.AcceptOfferResponse {
  case verify_auth(state) {
    Error(_) -> response_types.AcceptOfferResponseUnauthorized
    Ok(user) -> {
      case renting.accept_offer(state.conn, req.offer_id, user.id) {
        Ok(offer) -> {
          let _ =
            notify_other_participant(
              state,
              offer.rent_request_id,
              user.id,
              "offer.accepted",
              openapi_encode.encode_rent_offer_json(offer),
            )
          response_types.AcceptOfferResponseOk(offer)
        }
        Error(_) -> response_types.AcceptOfferResponseNotFound
      }
    }
  }
}

pub fn confirm_borrow(
  state: State,
  req: request_types.ConfirmBorrowRequest,
) -> response_types.ConfirmBorrowResponse {
  case verify_auth(state) {
    Error(_) -> response_types.ConfirmBorrowResponseUnauthorized
    Ok(user) -> {
      case renting.confirm_borrow(state.conn, req.request_id, user.id) {
        Ok(request) -> {
          let _ =
            notify_other_participant(
              state,
              req.request_id,
              user.id,
              "borrow.confirmed",
              openapi_encode.encode_rent_request_detail_json(request),
            )
          response_types.ConfirmBorrowResponseOk(request)
        }
        Error(_) -> response_types.ConfirmBorrowResponseForbidden
      }
    }
  }
}

pub fn confirm_return(
  state: State,
  req: request_types.ConfirmReturnRequest,
) -> response_types.ConfirmReturnResponse {
  case verify_auth(state) {
    Error(_) -> response_types.ConfirmReturnResponseUnauthorized
    Ok(user) -> {
      case renting.confirm_return(state.conn, req.request_id, user.id) {
        Ok(request) -> {
          let _ =
            notify_other_participant(
              state,
              req.request_id,
              user.id,
              "return.confirmed",
              openapi_encode.encode_rent_request_detail_json(request),
            )
          response_types.ConfirmReturnResponseOk(request)
        }
        Error(_) -> response_types.ConfirmReturnResponseForbidden
      }
    }
  }
}

pub fn mark_rent_request_read(
  state: State,
  req: request_types.MarkRentRequestReadRequest,
) -> response_types.MarkRentRequestReadResponse {
  case verify_auth(state) {
    Error(_) -> response_types.MarkRentRequestReadResponseUnauthorized
    Ok(user) -> {
      case renting.mark_rent_request_read(state.conn, req.request_id, user.id) {
        Ok(_) -> response_types.MarkRentRequestReadResponseNoContent
        Error(_) -> response_types.MarkRentRequestReadResponseNotFound
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

fn notify_other_participant(
  state: State,
  request_id: Int,
  current_user_id: Int,
  event_type: String,
  data: json.Json,
) -> Nil {
  let _ = case sql.get_rent_request_by_id(state.conn, request_id) {
    Ok(returned) -> {
      case list.first(returned.rows) {
        Ok(row) -> {
          let other_id = case row.requester_id == current_user_id {
            True -> row.owner_id
            False -> row.requester_id
          }
          let payload =
            json.to_string(
              json.object([
                #("type", json.string(event_type)),
                #("rent_request_id", json.int(request_id)),
                #("data", data),
              ]),
            )
          notifications.notify(
            state.registry,
            other_id,
            notifications.NotifyEvent(payload),
          )
        }
        _ -> Nil
      }
    }
    _ -> Nil
  }
  Nil
}
