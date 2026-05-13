//// Generated from Shareloop API v1.0.0

import gleam/dynamic/decode.{type Decoder}
import gleam/json.{type Json}
import gleam/option.{type Option, None, Some}

pub type Distance {
  Distance(
    km: Float,
  )
}

pub type FeaturedItem {
  FeaturedItem(
    author: Person,
    description: String,
    distance: Distance,
    score: Float,
    title: String,
  )
}

pub type Person {
  Person(
    name: String,
  )
}

pub fn distance_decoder() -> Decoder(Distance) {
  use km <- decode.field("km", decode.float)
  decode.success(Distance(km: km))
}

pub fn featured_item_decoder() -> Decoder(FeaturedItem) {
  use author <- decode.field("author", person_decoder())
  use description <- decode.field("description", decode.string)
  use distance <- decode.field("distance", distance_decoder())
  use score <- decode.field("score", decode.float)
  use title <- decode.field("title", decode.string)
  decode.success(FeaturedItem(author: author, description: description, distance: distance, score: score, title: title))
}

pub fn person_decoder() -> Decoder(Person) {
  use name <- decode.field("name", decode.string)
  decode.success(Person(name: name))
}

pub fn encode_distance(value: Distance) -> Json {
  json.object([
    #("km", json.float(value.km)),
  ])
}

pub fn encode_featured_item(value: FeaturedItem) -> Json {
  json.object([
    #("author", encode_person(value.author)),
    #("description", json.string(value.description)),
    #("distance", encode_distance(value.distance)),
    #("score", json.float(value.score)),
    #("title", json.string(value.title)),
  ])
}

pub fn encode_person(value: Person) -> Json {
  json.object([
    #("name", json.string(value.name)),
  ])
}
