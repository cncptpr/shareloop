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

pub type FeaturedItem {
  FeaturedItem(
    author: Person,
    city: Option(String),
    description: String,
    distance: Option(Distance),
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

pub fn featured_item_decoder() -> Decoder(FeaturedItem) {
  use author <- decode.field("author", person_decoder())
  use city <- decode.optional_field("city", None, decode.optional(decode.string))
  use description <- decode.field("description", decode.string)
  use distance <- decode.optional_field("distance", None, decode.optional(distance_decoder()))
  use postal_code <- decode.optional_field("postalCode", None, decode.optional(decode.string))
  use score <- decode.field("score", decode.float)
  use title <- decode.field("title", decode.string)
  decode.success(FeaturedItem(author: author, city: city, description: description, distance: distance, postal_code: postal_code, score: score, title: title))
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

pub fn encode_user(value: User) -> Json {
  json.object([
    #("createdAt", json.string(value.created_at)),
    #("email", json.string(value.email)),
    #("id", json.int(value.id)),
    #("lastOnlineAt", json.string(value.last_online_at)),
  ])
}
