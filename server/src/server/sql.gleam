//// This module contains the code to run the sql queries defined in
//// `./src/server/sql`.
//// > 🐿️ This module was generated automatically using v4.6.0 of
//// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
////

import gleam/dynamic/decode
import gleam/option.{type Option}
import gleam/time/timestamp.{type Timestamp}
import pog
import youid/uuid.{type Uuid}

/// A row you get from running the `create_item` query
/// defined in `./src/server/sql/create_item.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateItemRow {
  CreateItemRow(id: Int)
}

/// Runs the `create_item` query
/// defined in `./src/server/sql/create_item.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_item(
  db: pog.Connection,
  arg_1: String,
  arg_2: String,
  arg_3: Int,
  arg_4: Float,
  arg_5: Float,
  arg_6: Float,
  arg_7: String,
  arg_8: String,
) -> Result(pog.Returned(CreateItemRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    decode.success(CreateItemRow(id:))
  }

  "INSERT INTO items (title, description, author_id, score, location, city, postal_code) VALUES ($1, $2, $3, $4, st_setsrid(st_makepoint($5, $6), 4326)::geography, $7, $8)
returning id
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.int(arg_3))
  |> pog.parameter(pog.float(arg_4))
  |> pog.parameter(pog.float(arg_5))
  |> pog.parameter(pog.float(arg_6))
  |> pog.parameter(pog.text(arg_7))
  |> pog.parameter(pog.text(arg_8))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `create_profile` query
/// defined in `./src/server/sql/create_profile.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_profile(
  db: pog.Connection,
  arg_1: Int,
  arg_2: String,
  arg_3: String,
  arg_4: Float,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "INSERT INTO profiles (id, name, bio, rating) VALUES ($1, $2, $3, $4)
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.float(arg_4))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create_session` query
/// defined in `./src/server/sql/create_session.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateSessionRow {
  CreateSessionRow(id: Int)
}

/// Runs the `create_session` query
/// defined in `./src/server/sql/create_session.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_session(
  db: pog.Connection,
  arg_1: String,
  arg_2: Int,
  arg_3: Timestamp,
  arg_4: String,
  arg_5: Timestamp,
) -> Result(pog.Returned(CreateSessionRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    decode.success(CreateSessionRow(id:))
  }

  "insert into sessions (token_hash, user_id, expires_at, refresh_token_hash, refresh_expires_at) values ($1, $2, $3, $4, $5) returning id
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.int(arg_2))
  |> pog.parameter(pog.timestamp(arg_3))
  |> pog.parameter(pog.text(arg_4))
  |> pog.parameter(pog.timestamp(arg_5))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `create_user` query
/// defined in `./src/server/sql/create_user.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type CreateUserRow {
  CreateUserRow(id: Int)
}

/// Runs the `create_user` query
/// defined in `./src/server/sql/create_user.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn create_user(
  db: pog.Connection,
  arg_1: String,
  arg_2: String,
) -> Result(pog.Returned(CreateUserRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    decode.success(CreateUserRow(id:))
  }

  "insert into users (email, password_hash) values ($1, $2) returning id
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.text(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_all_items` query
/// defined in `./src/server/sql/delete_all_items.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_all_items(
  db: pog.Connection,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM items
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_all_profiles` query
/// defined in `./src/server/sql/delete_all_profiles.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_all_profiles(
  db: pog.Connection,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM profiles
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_all_users` query
/// defined in `./src/server/sql/delete_all_users.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_all_users(
  db: pog.Connection,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "DELETE FROM users
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_session` query
/// defined in `./src/server/sql/delete_session.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_session(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "delete from sessions where id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `delete_user_sessions` query
/// defined in `./src/server/sql/delete_user_sessions.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn delete_user_sessions(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "delete from sessions where user_id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `expire_session_access` query
/// defined in `./src/server/sql/expire_session_access.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn expire_session_access(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "update sessions set expires_at = now() where id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `expire_session_access_for_email` query
/// defined in `./src/server/sql/expire_session_access_for_email.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn expire_session_access_for_email(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "update sessions
set expires_at = now()
where user_id = (
    select id
    from users
    where email = $1
)
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `expire_session_refresh` query
/// defined in `./src/server/sql/expire_session_refresh.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn expire_session_refresh(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "update sessions set refresh_expires_at = now() where id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `expire_session_refresh_for_email` query
/// defined in `./src/server/sql/expire_session_refresh_for_email.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn expire_session_refresh_for_email(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "update sessions
set refresh_expires_at = now()
where user_id = (
    select id
    from users
    where email = $1
)
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_featured_items` query
/// defined in `./src/server/sql/get_featured_items.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetFeaturedItemsRow {
  GetFeaturedItemsRow(
    id: Int,
    title: String,
    description: String,
    author_name: String,
    score: Float,
    city: Option(String),
    postal_code: Option(String),
    distance_km: Float,
    first_image_uuid: Option(Uuid),
  )
}

/// Runs the `get_featured_items` query
/// defined in `./src/server/sql/get_featured_items.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_featured_items(
  db: pog.Connection,
  arg_1: Float,
  arg_2: Float,
) -> Result(pog.Returned(GetFeaturedItemsRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use title <- decode.field(1, decode.string)
    use description <- decode.field(2, decode.string)
    use author_name <- decode.field(3, decode.string)
    use score <- decode.field(4, decode.float)
    use city <- decode.field(5, decode.optional(decode.string))
    use postal_code <- decode.field(6, decode.optional(decode.string))
    use distance_km <- decode.field(7, decode.float)
    use first_image_uuid <- decode.field(8, decode.optional(uuid_decoder()))
    decode.success(GetFeaturedItemsRow(
      id:,
      title:,
      description:,
      author_name:,
      score:,
      city:,
      postal_code:,
      distance_km:,
      first_image_uuid:,
    ))
  }

  "select
  items.id,
  items.title,
  items.description,
  profiles.name as author_name,
  items.score,
  items.city,
  items.postal_code,
  coalesce(
    st_distance(location, st_setsrid(st_makepoint($2, $1), 4326)::geography) / 1000,
    0.0
  ) as distance_km,
  first_img.id as first_image_uuid
from items, profiles
left join lateral (
  select id
  from item_images
  where item_images.item_id = items.id
  order by sort_order, created_at
  limit 1
) as first_img on true
where items.author_id = profiles.id
order by score desc"
  |> pog.query
  |> pog.parameter(pog.float(arg_1))
  |> pog.parameter(pog.float(arg_2))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_featured_items_without_distance` query
/// defined in `./src/server/sql/get_featured_items_without_distance.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetFeaturedItemsWithoutDistanceRow {
  GetFeaturedItemsWithoutDistanceRow(
    id: Int,
    title: String,
    description: String,
    author_name: String,
    score: Float,
    city: Option(String),
    postal_code: Option(String),
    first_image_uuid: Option(Uuid),
  )
}

/// Runs the `get_featured_items_without_distance` query
/// defined in `./src/server/sql/get_featured_items_without_distance.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_featured_items_without_distance(
  db: pog.Connection,
) -> Result(pog.Returned(GetFeaturedItemsWithoutDistanceRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use title <- decode.field(1, decode.string)
    use description <- decode.field(2, decode.string)
    use author_name <- decode.field(3, decode.string)
    use score <- decode.field(4, decode.float)
    use city <- decode.field(5, decode.optional(decode.string))
    use postal_code <- decode.field(6, decode.optional(decode.string))
    use first_image_uuid <- decode.field(7, decode.optional(uuid_decoder()))
    decode.success(GetFeaturedItemsWithoutDistanceRow(
      id:,
      title:,
      description:,
      author_name:,
      score:,
      city:,
      postal_code:,
      first_image_uuid:,
    ))
  }

  "select
  items.id,
  items.title,
  items.description,
  profiles.name as author_name,
  items.score,
  items.city,
  items.postal_code,
  first_img.id as first_image_uuid
from items, profiles
left join lateral (
  select id
  from item_images
  where item_images.item_id = items.id
  order by sort_order, created_at
  limit 1
) as first_img on true
where items.author_id = profiles.id
order by score desc"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_item_by_id` query
/// defined in `./src/server/sql/get_item_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetItemByIdRow {
  GetItemByIdRow(
    id: Int,
    title: String,
    description: String,
    author_name: String,
    score: Float,
    city: Option(String),
    postal_code: Option(String),
    created_at: String,
  )
}

/// Runs the `get_item_by_id` query
/// defined in `./src/server/sql/get_item_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_item_by_id(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(GetItemByIdRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use title <- decode.field(1, decode.string)
    use description <- decode.field(2, decode.string)
    use author_name <- decode.field(3, decode.string)
    use score <- decode.field(4, decode.float)
    use city <- decode.field(5, decode.optional(decode.string))
    use postal_code <- decode.field(6, decode.optional(decode.string))
    use created_at <- decode.field(7, decode.string)
    decode.success(GetItemByIdRow(
      id:,
      title:,
      description:,
      author_name:,
      score:,
      city:,
      postal_code:,
      created_at:,
    ))
  }

  "select
  items.id,
  items.title,
  items.description,
  profiles.name as author_name,
  items.score,
  items.city,
  items.postal_code,
  items.created_at::text as created_at
from items, profiles
where items.id = $1 and items.author_id = profiles.id"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_item_image` query
/// defined in `./src/server/sql/get_item_image.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetItemImageRow {
  GetItemImageRow(
    id: Uuid,
    item_id: Int,
    original_name: String,
    mime_type: String,
  )
}

/// Runs the `get_item_image` query
/// defined in `./src/server/sql/get_item_image.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_item_image(
  db: pog.Connection,
  arg_1: Uuid,
) -> Result(pog.Returned(GetItemImageRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    use item_id <- decode.field(1, decode.int)
    use original_name <- decode.field(2, decode.string)
    use mime_type <- decode.field(3, decode.string)
    decode.success(GetItemImageRow(id:, item_id:, original_name:, mime_type:))
  }

  "SELECT id, item_id, original_name, mime_type
FROM item_images
WHERE id = $1"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_item_images_for_item` query
/// defined in `./src/server/sql/get_item_images_for_item.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetItemImagesForItemRow {
  GetItemImagesForItemRow(id: Uuid)
}

/// Runs the `get_item_images_for_item` query
/// defined in `./src/server/sql/get_item_images_for_item.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_item_images_for_item(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(GetItemImagesForItemRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    decode.success(GetItemImagesForItemRow(id:))
  }

  "select id from item_images where item_id = $1 order by sort_order, created_at"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_profile` query
/// defined in `./src/server/sql/get_profile.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetProfileRow {
  GetProfileRow(
    id: Int,
    name: String,
    bio: Option(String),
    rating: Option(Float),
  )
}

/// Runs the `get_profile` query
/// defined in `./src/server/sql/get_profile.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_profile(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(GetProfileRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use name <- decode.field(1, decode.string)
    use bio <- decode.field(2, decode.optional(decode.string))
    use rating <- decode.field(3, decode.optional(pog.numeric_decoder()))
    decode.success(GetProfileRow(id:, name:, bio:, rating:))
  }

  "SELECT id, name, bio, rating
FROM profiles
WHERE id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_session_by_refresh_token` query
/// defined in `./src/server/sql/get_session_by_refresh_token.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetSessionByRefreshTokenRow {
  GetSessionByRefreshTokenRow(
    id: Int,
    token_hash: String,
    user_id: Int,
    expires_at: Timestamp,
    created_at: Timestamp,
    refresh_token_hash: String,
    refresh_expires_at: Timestamp,
    email: String,
    last_online_at: Timestamp,
  )
}

/// Runs the `get_session_by_refresh_token` query
/// defined in `./src/server/sql/get_session_by_refresh_token.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_session_by_refresh_token(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(GetSessionByRefreshTokenRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use token_hash <- decode.field(1, decode.string)
    use user_id <- decode.field(2, decode.int)
    use expires_at <- decode.field(3, pog.timestamp_decoder())
    use created_at <- decode.field(4, pog.timestamp_decoder())
    use refresh_token_hash <- decode.field(5, decode.string)
    use refresh_expires_at <- decode.field(6, pog.timestamp_decoder())
    use email <- decode.field(7, decode.string)
    use last_online_at <- decode.field(8, pog.timestamp_decoder())
    decode.success(GetSessionByRefreshTokenRow(
      id:,
      token_hash:,
      user_id:,
      expires_at:,
      created_at:,
      refresh_token_hash:,
      refresh_expires_at:,
      email:,
      last_online_at:,
    ))
  }

  "select
  s.id, s.token_hash, s.user_id, s.expires_at, s.created_at,
  s.refresh_token_hash, s.refresh_expires_at,
  u.email, u.last_online_at
from sessions s
join users u on s.user_id = u.id
where s.refresh_token_hash = $1
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_session_by_token` query
/// defined in `./src/server/sql/get_session_by_token.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetSessionByTokenRow {
  GetSessionByTokenRow(
    id: Int,
    token_hash: String,
    user_id: Int,
    expires_at: Timestamp,
    created_at: Timestamp,
    refresh_token_hash: String,
    refresh_expires_at: Timestamp,
    email: String,
    last_online_at: Timestamp,
  )
}

/// Runs the `get_session_by_token` query
/// defined in `./src/server/sql/get_session_by_token.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_session_by_token(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(GetSessionByTokenRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use token_hash <- decode.field(1, decode.string)
    use user_id <- decode.field(2, decode.int)
    use expires_at <- decode.field(3, pog.timestamp_decoder())
    use created_at <- decode.field(4, pog.timestamp_decoder())
    use refresh_token_hash <- decode.field(5, decode.string)
    use refresh_expires_at <- decode.field(6, pog.timestamp_decoder())
    use email <- decode.field(7, decode.string)
    use last_online_at <- decode.field(8, pog.timestamp_decoder())
    decode.success(GetSessionByTokenRow(
      id:,
      token_hash:,
      user_id:,
      expires_at:,
      created_at:,
      refresh_token_hash:,
      refresh_expires_at:,
      email:,
      last_online_at:,
    ))
  }

  "select
  s.id, s.token_hash, s.user_id, s.expires_at, s.created_at,
  s.refresh_token_hash, s.refresh_expires_at,
  u.email, u.last_online_at
from sessions s
join users u on s.user_id = u.id
where s.token_hash = $1
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_user_by_email` query
/// defined in `./src/server/sql/get_user_by_email.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByEmailRow {
  GetUserByEmailRow(
    id: Int,
    email: String,
    password_hash: String,
    last_online_at: Timestamp,
    created_at: Timestamp,
  )
}

/// Runs the `get_user_by_email` query
/// defined in `./src/server/sql/get_user_by_email.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_email(
  db: pog.Connection,
  arg_1: String,
) -> Result(pog.Returned(GetUserByEmailRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use email <- decode.field(1, decode.string)
    use password_hash <- decode.field(2, decode.string)
    use last_online_at <- decode.field(3, pog.timestamp_decoder())
    use created_at <- decode.field(4, pog.timestamp_decoder())
    decode.success(GetUserByEmailRow(
      id:,
      email:,
      password_hash:,
      last_online_at:,
      created_at:,
    ))
  }

  "select id, email, password_hash, last_online_at, created_at
from users
where email = $1
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `get_user_by_id` query
/// defined in `./src/server/sql/get_user_by_id.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type GetUserByIdRow {
  GetUserByIdRow(
    id: Int,
    email: String,
    password_hash: String,
    last_online_at: Timestamp,
    created_at: Timestamp,
  )
}

/// Runs the `get_user_by_id` query
/// defined in `./src/server/sql/get_user_by_id.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn get_user_by_id(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(GetUserByIdRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use email <- decode.field(1, decode.string)
    use password_hash <- decode.field(2, decode.string)
    use last_online_at <- decode.field(3, pog.timestamp_decoder())
    use created_at <- decode.field(4, pog.timestamp_decoder())
    decode.success(GetUserByIdRow(
      id:,
      email:,
      password_hash:,
      last_online_at:,
      created_at:,
    ))
  }

  "select id, email, password_hash, last_online_at, created_at
from users
where id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `insert_item_image` query
/// defined in `./src/server/sql/insert_item_image.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type InsertItemImageRow {
  InsertItemImageRow(id: Uuid)
}

/// Runs the `insert_item_image` query
/// defined in `./src/server/sql/insert_item_image.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn insert_item_image(
  db: pog.Connection,
  arg_1: Uuid,
  arg_2: Int,
  arg_3: String,
  arg_4: String,
  arg_5: Int,
) -> Result(pog.Returned(InsertItemImageRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, uuid_decoder())
    decode.success(InsertItemImageRow(id:))
  }

  "INSERT INTO item_images (id, item_id, original_name, mime_type, sort_order)
VALUES ($1, $2, $3, $4, $5)
returning id"
  |> pog.query
  |> pog.parameter(pog.text(uuid.to_string(arg_1)))
  |> pog.parameter(pog.int(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.text(arg_4))
  |> pog.parameter(pog.int(arg_5))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `list_sessions` query
/// defined in `./src/server/sql/list_sessions.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type ListSessionsRow {
  ListSessionsRow(
    id: Int,
    token_hash: String,
    user_id: Int,
    expires_at: Timestamp,
    created_at: Timestamp,
    refresh_token_hash: String,
    refresh_expires_at: Timestamp,
    email: String,
  )
}

/// Runs the `list_sessions` query
/// defined in `./src/server/sql/list_sessions.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn list_sessions(
  db: pog.Connection,
) -> Result(pog.Returned(ListSessionsRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use token_hash <- decode.field(1, decode.string)
    use user_id <- decode.field(2, decode.int)
    use expires_at <- decode.field(3, pog.timestamp_decoder())
    use created_at <- decode.field(4, pog.timestamp_decoder())
    use refresh_token_hash <- decode.field(5, decode.string)
    use refresh_expires_at <- decode.field(6, pog.timestamp_decoder())
    use email <- decode.field(7, decode.string)
    decode.success(ListSessionsRow(
      id:,
      token_hash:,
      user_id:,
      expires_at:,
      created_at:,
      refresh_token_hash:,
      refresh_expires_at:,
      email:,
    ))
  }

  "select s.id, s.token_hash, s.user_id, s.expires_at, s.created_at,
       s.refresh_token_hash, s.refresh_expires_at, u.email
from sessions s
join users u on s.user_id = u.id
order by s.created_at desc
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// A row you get from running the `list_users` query
/// defined in `./src/server/sql/list_users.sql`.
///
/// > 🐿️ This type definition was generated automatically using v4.6.0 of the
/// > [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub type ListUsersRow {
  ListUsersRow(
    id: Int,
    email: String,
    last_online_at: Timestamp,
    created_at: Timestamp,
  )
}

/// Runs the `list_users` query
/// defined in `./src/server/sql/list_users.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn list_users(
  db: pog.Connection,
) -> Result(pog.Returned(ListUsersRow), pog.QueryError) {
  let decoder = {
    use id <- decode.field(0, decode.int)
    use email <- decode.field(1, decode.string)
    use last_online_at <- decode.field(2, pog.timestamp_decoder())
    use created_at <- decode.field(3, pog.timestamp_decoder())
    decode.success(ListUsersRow(id:, email:, last_online_at:, created_at:))
  }

  "select id, email, last_online_at, created_at from users order by id
"
  |> pog.query
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `update_last_online` query
/// defined in `./src/server/sql/update_last_online.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_last_online(
  db: pog.Connection,
  arg_1: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "update users set last_online_at = now() where id = $1
"
  |> pog.query
  |> pog.parameter(pog.int(arg_1))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

/// Runs the `update_session_tokens` query
/// defined in `./src/server/sql/update_session_tokens.sql`.
///
/// > 🐿️ This function was generated automatically using v4.6.0 of
/// > the [squirrel package](https://github.com/giacomocavalieri/squirrel).
///
pub fn update_session_tokens(
  db: pog.Connection,
  arg_1: String,
  arg_2: Timestamp,
  arg_3: String,
  arg_4: Timestamp,
  arg_5: Int,
) -> Result(pog.Returned(Nil), pog.QueryError) {
  let decoder = decode.map(decode.dynamic, fn(_) { Nil })

  "update sessions
set token_hash = $1, expires_at = $2, refresh_token_hash = $3, refresh_expires_at = $4
where id = $5
"
  |> pog.query
  |> pog.parameter(pog.text(arg_1))
  |> pog.parameter(pog.timestamp(arg_2))
  |> pog.parameter(pog.text(arg_3))
  |> pog.parameter(pog.timestamp(arg_4))
  |> pog.parameter(pog.int(arg_5))
  |> pog.returning(decoder)
  |> pog.execute(db)
}

// --- Encoding/decoding utils -------------------------------------------------

/// A decoder to decode `Uuid`s coming from a Postgres query.
///
fn uuid_decoder() {
  use bit_array <- decode.then(decode.bit_array)
  case uuid.from_bit_array(bit_array) {
    Ok(uuid) -> decode.success(uuid)
    Error(_) -> decode.failure(uuid.v7(), "Uuid")
  }
}
