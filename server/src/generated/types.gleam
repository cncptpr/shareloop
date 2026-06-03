//// Generated from Shareloop API v1.0.0

import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}

pub type CreateItemRequest {
  CreateItemRequest(
    city: String,
    description: String,
    lat: Float,
    lng: Float,
    postal_code: String,
    title: String,
  )
}

pub type CreateItemResponse {
  CreateItemResponse(
    id: Int,
  )
}

pub type Distance {
  Distance(
    km: Float,
  )
}

pub type EditItemImagesRequest {
  EditItemImagesRequest(
    delete: List(String),
    reorder: List(ReorderEntry),
  )
}

pub type FeaturedItem {
  FeaturedItem(
    author: Person,
    city: Option(String),
    description: String,
    distance: Option(Distance),
    id: Int,
    image_uuid: Option(String),
    postal_code: Option(String),
    score: Float,
    title: String,
  )
}

pub type ItemDetail {
  ItemDetail(
    author: Person,
    author_id: Int,
    category: Option(String),
    city: Option(String),
    created_at: String,
    description: String,
    id: Int,
    image_uuids: Option(List(String)),
    postal_code: Option(String),
    score: Float,
    title: String,
  )
}

pub type LatLng {
  LatLng(
    lat: Float,
    lng: Float,
  )
}

pub type LoginRequest {
  LoginRequest(
    email: String,
    password: String,
  )
}

pub type LoginResult {
  LoginResult(
    access_expires_at: String,
    access_token: String,
    refresh_expires_at: String,
    refresh_token: String,
    user: User,
  )
}

pub type Person {
  Person(
    name: String,
  )
}

pub type RefreshRequest {
  RefreshRequest(
    refresh_token: String,
  )
}

pub type ReorderEntry {
  ReorderEntry(
    sort_order: Int,
    uuid: String,
  )
}

pub type UpdateItemRequest {
  UpdateItemRequest(
    city: String,
    description: String,
    lat: Float,
    lng: Float,
    postal_code: String,
    title: String,
  )
}

pub type UploadItemImageRequest {
  UploadItemImageRequest(
    data: String,
    filename: String,
    sort_order: Int,
  )
}

pub type UploadItemImageResponse {
  UploadItemImageResponse(
    uuid: String,
  )
}

pub type User {
  User(
    created_at: String,
    email: String,
    id: Int,
    last_online_at: String,
  )
}

pub fn create_item_request_decoder() -> Decoder(CreateItemRequest) {
  use city <- decode.field("city", decode.string)
  use description <- decode.field("description", decode.string)
  use lat <- decode.field("lat", decode.float)
  use lng <- decode.field("lng", decode.float)
  use postal_code <- decode.field("postalCode", decode.string)
  use title <- decode.field("title", decode.string)
  decode.success(CreateItemRequest(city: city, description: description, lat: lat, lng: lng, postal_code: postal_code, title: title))
}

pub fn create_item_response_decoder() -> Decoder(CreateItemResponse) {
  use id <- decode.field("id", decode.int)
  decode.success(CreateItemResponse(id: id))
}

pub fn distance_decoder() -> Decoder(Distance) {
  use km <- decode.field("km", decode.float)
  decode.success(Distance(km: km))
}

pub fn edit_item_images_request_decoder() -> Decoder(EditItemImagesRequest) {
  use delete <- decode.field("delete", decode.list(decode.string))
  use reorder <- decode.field("reorder", decode.list(reorder_entry_decoder()))
  decode.success(EditItemImagesRequest(delete: delete, reorder: reorder))
}

pub fn featured_item_decoder() -> Decoder(FeaturedItem) {
  use author <- decode.field("author", person_decoder())
  use city <- decode.optional_field("city", None, decode.optional(decode.string))
  use description <- decode.field("description", decode.string)
  use distance <- decode.optional_field("distance", None, decode.optional(distance_decoder()))
  use id <- decode.field("id", decode.int)
  use image_uuid <- decode.optional_field("imageUuid", None, decode.optional(decode.string))
  use postal_code <- decode.optional_field("postalCode", None, decode.optional(decode.string))
  use score <- decode.field("score", decode.float)
  use title <- decode.field("title", decode.string)
  decode.success(FeaturedItem(author: author, city: city, description: description, distance: distance, id: id, image_uuid: image_uuid, postal_code: postal_code, score: score, title: title))
}

pub fn item_detail_decoder() -> Decoder(ItemDetail) {
  use author <- decode.field("author", person_decoder())
  use author_id <- decode.field("authorId", decode.int)
  use category <- decode.optional_field("category", None, decode.optional(decode.string))
  use city <- decode.optional_field("city", None, decode.optional(decode.string))
  use created_at <- decode.field("createdAt", decode.string)
  use description <- decode.field("description", decode.string)
  use id <- decode.field("id", decode.int)
  use image_uuids <- decode.optional_field("imageUuids", None, decode.optional(decode.list(decode.string)))
  use postal_code <- decode.optional_field("postalCode", None, decode.optional(decode.string))
  use score <- decode.field("score", decode.float)
  use title <- decode.field("title", decode.string)
  decode.success(ItemDetail(author: author, author_id: author_id, category: category, city: city, created_at: created_at, description: description, id: id, image_uuids: image_uuids, postal_code: postal_code, score: score, title: title))
}

pub fn lat_lng_decoder() -> Decoder(LatLng) {
  use lat <- decode.field("lat", decode.float)
  use lng <- decode.field("lng", decode.float)
  decode.success(LatLng(lat: lat, lng: lng))
}

pub fn login_request_decoder() -> Decoder(LoginRequest) {
  use email <- decode.field("email", decode.string)
  use password <- decode.field("password", decode.string)
  decode.success(LoginRequest(email: email, password: password))
}

pub fn login_result_decoder() -> Decoder(LoginResult) {
  use access_expires_at <- decode.field("accessExpiresAt", decode.string)
  use access_token <- decode.field("accessToken", decode.string)
  use refresh_expires_at <- decode.field("refreshExpiresAt", decode.string)
  use refresh_token <- decode.field("refreshToken", decode.string)
  use user <- decode.field("user", user_decoder())
  decode.success(LoginResult(access_expires_at: access_expires_at, access_token: access_token, refresh_expires_at: refresh_expires_at, refresh_token: refresh_token, user: user))
}

pub fn person_decoder() -> Decoder(Person) {
  use name <- decode.field("name", decode.string)
  decode.success(Person(name: name))
}

pub fn refresh_request_decoder() -> Decoder(RefreshRequest) {
  use refresh_token <- decode.field("refreshToken", decode.string)
  decode.success(RefreshRequest(refresh_token: refresh_token))
}

pub fn reorder_entry_decoder() -> Decoder(ReorderEntry) {
  use sort_order <- decode.field("sortOrder", decode.int)
  use uuid <- decode.field("uuid", decode.string)
  decode.success(ReorderEntry(sort_order: sort_order, uuid: uuid))
}

pub fn update_item_request_decoder() -> Decoder(UpdateItemRequest) {
  use city <- decode.field("city", decode.string)
  use description <- decode.field("description", decode.string)
  use lat <- decode.field("lat", decode.float)
  use lng <- decode.field("lng", decode.float)
  use postal_code <- decode.field("postalCode", decode.string)
  use title <- decode.field("title", decode.string)
  decode.success(UpdateItemRequest(city: city, description: description, lat: lat, lng: lng, postal_code: postal_code, title: title))
}

pub fn upload_item_image_request_decoder() -> Decoder(UploadItemImageRequest) {
  use data <- decode.field("data", decode.string)
  use filename <- decode.field("filename", decode.string)
  use sort_order <- decode.field("sortOrder", decode.int)
  decode.success(UploadItemImageRequest(data: data, filename: filename, sort_order: sort_order))
}

pub fn upload_item_image_response_decoder() -> Decoder(UploadItemImageResponse) {
  use uuid <- decode.field("uuid", decode.string)
  decode.success(UploadItemImageResponse(uuid: uuid))
}

pub fn user_decoder() -> Decoder(User) {
  use created_at <- decode.field("createdAt", decode.string)
  use email <- decode.field("email", decode.string)
  use id <- decode.field("id", decode.int)
  use last_online_at <- decode.field("lastOnlineAt", decode.string)
  decode.success(User(created_at: created_at, email: email, id: id, last_online_at: last_online_at))
}

pub fn encode_create_item_request(value: CreateItemRequest) -> Json {
  json.object([
    #("city", json.string(value.city)),
    #("description", json.string(value.description)),
    #("lat", json.float(value.lat)),
    #("lng", json.float(value.lng)),
    #("postalCode", json.string(value.postal_code)),
    #("title", json.string(value.title)),
  ])
}

pub fn encode_create_item_response(value: CreateItemResponse) -> Json {
  json.object([
    #("id", json.int(value.id)),
  ])
}

pub fn encode_distance(value: Distance) -> Json {
  json.object([
    #("km", json.float(value.km)),
  ])
}

pub fn encode_edit_item_images_request(value: EditItemImagesRequest) -> Json {
  json.object([
    #("delete", json.array(value.delete, fn(item) { json.string(item) })),
    #("reorder", json.array(value.reorder, fn(item) { encode_reorder_entry(item) })),
  ])
}

pub fn encode_featured_item(value: FeaturedItem) -> Json {
  json.object([
    #("author", encode_person(value.author)),
    #("city", case value.city {
      Some(v) -> json.string(v)
      None -> json.null()
    }),
    #("description", json.string(value.description)),
    #("distance", case value.distance {
      Some(v) -> encode_distance(v)
      None -> json.null()
    }),
    #("id", json.int(value.id)),
    #("imageUuid", case value.image_uuid {
      Some(v) -> json.string(v)
      None -> json.null()
    }),
    #("postalCode", case value.postal_code {
      Some(v) -> json.string(v)
      None -> json.null()
    }),
    #("score", json.float(value.score)),
    #("title", json.string(value.title)),
  ])
}

pub fn encode_item_detail(value: ItemDetail) -> Json {
  json.object([
    #("author", encode_person(value.author)),
    #("authorId", json.int(value.author_id)),
    #("category", case value.category {
      Some(v) -> json.string(v)
      None -> json.null()
    }),
    #("city", case value.city {
      Some(v) -> json.string(v)
      None -> json.null()
    }),
    #("createdAt", json.string(value.created_at)),
    #("description", json.string(value.description)),
    #("id", json.int(value.id)),
    #("imageUuids", case value.image_uuids {
      Some(v) -> json.array(v, fn(item) { json.string(item) })
      None -> json.null()
    }),
    #("postalCode", case value.postal_code {
      Some(v) -> json.string(v)
      None -> json.null()
    }),
    #("score", json.float(value.score)),
    #("title", json.string(value.title)),
  ])
}

pub fn encode_lat_lng(value: LatLng) -> Json {
  json.object([
    #("lat", json.float(value.lat)),
    #("lng", json.float(value.lng)),
  ])
}

pub fn encode_login_request(value: LoginRequest) -> Json {
  json.object([
    #("email", json.string(value.email)),
    #("password", json.string(value.password)),
  ])
}

pub fn encode_login_result(value: LoginResult) -> Json {
  json.object([
    #("accessExpiresAt", json.string(value.access_expires_at)),
    #("accessToken", json.string(value.access_token)),
    #("refreshExpiresAt", json.string(value.refresh_expires_at)),
    #("refreshToken", json.string(value.refresh_token)),
    #("user", encode_user(value.user)),
  ])
}

pub fn encode_person(value: Person) -> Json {
  json.object([
    #("name", json.string(value.name)),
  ])
}

pub fn encode_refresh_request(value: RefreshRequest) -> Json {
  json.object([
    #("refreshToken", json.string(value.refresh_token)),
  ])
}

pub fn encode_reorder_entry(value: ReorderEntry) -> Json {
  json.object([
    #("sortOrder", json.int(value.sort_order)),
    #("uuid", json.string(value.uuid)),
  ])
}

pub fn encode_update_item_request(value: UpdateItemRequest) -> Json {
  json.object([
    #("city", json.string(value.city)),
    #("description", json.string(value.description)),
    #("lat", json.float(value.lat)),
    #("lng", json.float(value.lng)),
    #("postalCode", json.string(value.postal_code)),
    #("title", json.string(value.title)),
  ])
}

pub fn encode_upload_item_image_request(value: UploadItemImageRequest) -> Json {
  json.object([
    #("data", json.string(value.data)),
    #("filename", json.string(value.filename)),
    #("sortOrder", json.int(value.sort_order)),
  ])
}

pub fn encode_upload_item_image_response(value: UploadItemImageResponse) -> Json {
  json.object([
    #("uuid", json.string(value.uuid)),
  ])
}

pub fn encode_user(value: User) -> Json {
  json.object([
    #("createdAt", json.string(value.created_at)),
    #("email", json.string(value.email)),
    #("id", json.int(value.id)),
    #("lastOnlineAt", json.string(value.last_online_at)),
  ])
}
